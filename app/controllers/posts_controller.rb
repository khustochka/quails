# frozen_string_literal: true

class PostsController < ApplicationController
  include CorrectableConcern
  include PostsHelper
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper

  administrative except: [:show]
  localized only: [:show]

  before_action :find_post, only: [:edit, :update, :destroy, :for_lj, :lj_post]

  after_action :cache_expire, only: [:create, :update, :destroy]

  FILTER_KEYS = [:topic, :status, :lang_present, :lang_missing, :year, :month].freeze

  POST_ATTRS = [:title, :body, :face_date, :status, :lang, :lj_data, :post_core_id].freeze
  private_constant :POST_ATTRS

  # GET /posts — admin index, one row per PostCore.
  def index
    filters = params.permit(*FILTER_KEYS).to_h.symbolize_keys
    @filters = filters

    posts_scope = current_user.available_posts
    posts_filtered = false
    if filters[:status].present?
      posts_scope = posts_scope.where(status: filters[:status])
      posts_filtered = true
    end
    if filters[:lang_present].present?
      posts_scope = posts_scope.where(lang: filters[:lang_present])
      posts_filtered = true
    end
    if filters[:year].present?
      posts_scope = posts_scope.where("EXTRACT(year FROM face_date)::integer = ?", filters[:year].to_i)
      posts_filtered = true
    end
    if filters[:month].present?
      posts_scope = posts_scope.where("EXTRACT(month FROM face_date)::integer = ?", filters[:month].to_i)
      posts_filtered = true
    end

    # When any post-level filter is active, an INNER JOIN against the aggregate
    # keeps only cores with a matching translation. Without filters, use a LEFT
    # JOIN so empty cores (no translations yet) still appear in the listing.
    agg_sql = posts_scope.group(:post_core_id).select("post_core_id, MAX(face_date) AS max_face_date").to_sql
    join_type = posts_filtered ? "INNER JOIN" : "LEFT JOIN"
    cores = PostCore.joins(Arel.sql("#{join_type} (#{agg_sql}) agg ON agg.post_core_id = post_cores.id"))
    cores = cores.where(topic: filters[:topic]) if filters[:topic].present?
    if filters[:lang_missing].present?
      cores = cores.where.not(
        id: Post.where(lang: filters[:lang_missing]).select(:post_core_id)
      )
    end

    @cores = cores.order(Arel.sql("agg.max_face_date DESC NULLS FIRST"))
      .preload(:posts)
      .page(params[:page]).per(25)
  end

  # Legacy admin path — redirects to filtered index.
  def hidden
    redirect_to posts_path(status: "PRIV", page: params[:page])
  end

  def facebook
    @posts = Post.facebook_publishable.order(face_date: :desc).page(params[:page]).per(20)
  end

  # GET /posts/1
  def show
    if helpers.cyrillic_locale?
      exact = current_user.available_posts.where(lang: I18n.locale.to_s)
      fallback = current_user.available_posts.where(lang: LocaleHelper::CYRILLIC_LOCALES)
    else
      exact = fallback = current_user.available_posts.where(lang: "en")
    end

    core = PostCore.find_by(slug: params[:id])

    @post = (core && exact.find_by(post_core_id: core.id)) ||
      (core && fallback.find_by(post_core_id: core.id))

    if @post.nil?
      # Legacy slugs are only used for a handful of historical English posts;
      # all of them end in "-en". Only attempt the legacy lookup in that case.
      if params[:id].to_s.end_with?("-en")
        legacy_core = PostCore.find_by!(legacy_slug: params[:id])
        legacy_post = fallback.find_by!(post_core_id: legacy_core.id)
        redirect_to public_post_path(legacy_post), status: :moved_permanently
        return
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post), status: :moved_permanently
    end

    @localized_versions = @post.localized_versions(source: current_user.available_posts)
    @attach_core_id = @post.post_core_id if current_user.admin?
    @robots = "NOINDEX" if @post.status == "NIDX"
    @comments = current_user.available_comments(@post).group_by(&:parent_id)

    @post_body = cache([@post, I18n.locale, :post_body]) do
      @post.decorated(locale: I18n.locale).for_site.body
    end

    @meta_description = cache([@post, I18n.locale, :meta_description]) do
      truncate(strip_tags(@post_body), length: 150, separator: " ").gsub(/\s+/, " ")
    end

    screened = session[:screened]
    if screened
      screened = screened.with_indifferent_access
      screened_parent_id = screened.delete(:parent_id)
      @comments[screened_parent_id] ||= []
      @comments[screened_parent_id].push(CommentScreened.new(screened))
      session[:screened] = nil
    end

    @comment = @post.comments.new
    current_user.prepopulate_comment(@comment)
  end

  # GET /posts/new
  def new
    defaults = { status: "PRIV", face_date: Time.current.strftime("%F %T") }
    @post = Post.new(defaults.merge(post_attrs))
    if @post.post_core_id.blank?
      redirect_to new_post_core_path
      return
    end
    render "form"
  end

  # GET /posts/1/edit
  def edit
    set_correction_flash(@post)
    @extra_params = @post.to_url_params
    @localized_versions = @post.localized_versions(source: current_user.available_posts)
    render "form"
  end

  # POST /posts
  def create
    @post = Post.new(post_attrs)

    if @post.save
      redirect_to(universal_public_post_path(@post))
    else
      render "form"
    end
  end

  # PUT /posts/1
  def update
    @extra_params = @post.to_url_params
    # post_core_id is locked once a translation is created; rebinding goes
    # through PostCoresController, not here.
    update_params = post_attrs.except(:post_core_id)
    process_correction_options(@post) do
      if @post.update(update_params)
        redirect_to(redirect_after_update_path(@post))
      else
        render "form"
      end
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to(blog_url)
  end

  ALLOWED_COUNTRY_TAGS = %w(usa canada)

  def for_lj
    # Just render LJ version
    render body: @post.decorated({ host: request.host, port: request.port }).for_lj.body
  end

  # POST
  def lj_post
    server = LiveJournal::Server.new("Livejournal", "https://www.livejournal.com")
    user = LiveJournal::User.new(Settings.lj_user.name, Settings.lj_user.password, server)

    entry = LiveJournal::Entry.new
    entry.preformatted = true
    entry.security = :private unless Quails.env.live?
    # SafeBuffer breaks 'livejournal' gem, so we are not applying it to 'for_lj.body'
    # And `unsafing` the title with 'to_str'
    entry.subject = @post.decorated.title.to_str
    entry.event = @post.decorated({ host: request.host, port: request.port }).for_lj.body

    request = if @post.lj_data.url.present?
      if Quails.env.live?
        if @post.lj_data.url.include?("livejournal.com")
          entry.itemid = @post.lj_data.post_id
          LiveJournal::Request::EditEvent.new(user, entry)
        else
          flash.alert = "This entry is on Dreamwidth, cannot edit via LiveJournal."
          nil
        end
      else
        flash.alert = "Editing LJ/DW entries is prohibited when not on real production."
        nil
      end
    else
      any_card = @post.cards.first
      if any_card
        country_tag = any_card.locus.country.slug
        if country_tag.in?(ALLOWED_COUNTRY_TAGS)
          entry.taglist = [country_tag.tr("_", " ")]
        end
      end
      LiveJournal::Request::PostEvent.new(user, entry)
    end

    if request
      request.run
      flash.notice = "Posted to LJ"

      if entry.itemid
        @post.lj_data.post_id = entry.itemid
        if entry.anum
          @post.lj_data.url = "https://#{Settings.lj_user.name}.livejournal.com/#{entry.display_itemid}.html"
        end
        @post.save!
      end
    end

    respond_to do |format|
      format.html { redirect_to action: :edit }
      format.json do
        render json: flash.to_hash.merge(url: @post.lj_url), status: flash.alert ? 403 : 200
        flash.discard
      end
    end
  end

  private

  def post_attrs
    raw = params[:post] || ActionController::Parameters.new
    raw = ActionController::Parameters.new(raw) unless raw.is_a?(ActionController::Parameters)
    raw.permit(*POST_ATTRS).to_h.symbolize_keys
  end

  def find_post
    @post = current_user.available_posts.find(params[:id])
  end

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: "xml"
    expire_page controller: :feeds, action: :instant_articles, format: "xml"
    expire_photo_feeds
    expire_page controller: :feeds, action: :sitemap, format: "xml"
  end

  def default_redirect_path(record)
    universal_public_post_path(record)
  end
end
