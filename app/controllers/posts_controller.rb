# frozen_string_literal: true

class PostsController < ApplicationController
  include CorrectableConcern

  administrative except: [:show]

  before_action :find_post, only: [:edit, :update, :destroy, :show, :for_lj, :lj_post]

  after_action :cache_expire, only: [:create, :update, :destroy]

  # This is rendered in public layout, just raising exception when no posts are found (the case for regular user)
  def hidden
    @posts = Post.hidden.order(face_date: :desc).page(params[:page]).per(20)
  end

  def facebook
    @posts = Post.facebook_publishable.order(face_date: :desc).page(params[:page]).per(20)
  end

  # GET /posts/1
  def show
    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post), status: :moved_permanently
    end

    @robots = "NOINDEX" if @post.status == "NIDX"
    @comments = current_user.available_comments(@post).group_by(&:parent_id)

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
    @post = Post.new(topic: "OBSR", status: "PRIV")
    render "form"
  end

  # GET /posts/1/edit
  def edit
    set_correction_flash(@post)
    @extra_params = @post.to_url_params
    @observation_search = ObservationSearch.new
    render "form"
  end

  # POST /posts
  def create
    @post = Post.new(params[:post])

    if @post.save
      redirect_to(public_post_path(@post))
    else
      render "form"
    end
  end

  # PUT /posts/1
  def update
    @extra_params = @post.to_url_params
    process_correction_options(@post) do
      if @post.update(params[:post])
        redirect_to(redirect_after_update_path(@post))
      else
        @observation_search = ObservationSearch.new
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
        if /livejournal\.com/.match?(@post.lj_data.url)
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

  def find_post
    @post = current_user.available_posts.find_by!(slug: params[:id])
  end

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: "xml"
    expire_page controller: :feeds, action: :instant_articles, format: "xml"
    expire_photo_feeds
    expire_page controller: :feeds, action: :sitemap, format: "xml"
  end

  def default_redirect_path(record)
    public_post_path(record)
  end
end
