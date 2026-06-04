# frozen_string_literal: true

class SpeciesController < ApplicationController
  administrative except: [:gallery, :show, :search]
  localized only: [:gallery, :show, :search]

  before_action :find_species, only: [:edit, :update]

  # GET /species/admin
  def index
    # TODO : Filter by order, family
    @term = params[:term]
    @species = if @term.present?
      Search::SpeciesSearchUnweighted.new(Species.all, @term).find
    else
      Species.order(:index_num).page(params[:page]).per(50)
    end
    @species = @species.preload(:high_level_taxa, :url_synonyms)
    if params[:instant_search]
      render partial: "species/table", layout: false
    else
      render
    end
  end

  # GET /species
  def gallery
    @species = Species.joins(:image).includes(:image).ordered_by_taxonomy
    @feed = "photos"
  end

  # GET /species/1
  def show
    id_humanized = Species.humanize(params[:id])
    @species = Species.find_by(name_sci: id_humanized) || UrlSynonym.find_by(name_sci: id_humanized).try(:species)
    if @species
      if params[:id] != @species.to_param
        redirect_to @species, status: :moved_permanently
        # TODO: maybe show as a page but set different canonical, NOINDEX. Or redirect but show "redirected from" Like Wikipedia.
      else
        @observations_count = @species.observations.count
        if @observations_count.positive?
          available_posts = current_user.available_posts
            .where(post_core_id: @species.post_cores)
            .where(lang: Post::COMPATIBLE_LANGUAGES[I18n.locale] || [])
          ordered_core_ids = available_posts.group(:post_core_id)
            .order(Arel.sql("MAX(posts.face_date) DESC")).limit(10).pluck(:post_core_id)
          cores_by_id = PostCore.where(id: ordered_core_ids).index_by(&:id)
          localized_by_core = Post.localized_for(cores_by_id.values, I18n.locale, scope: current_user.available_posts)
          @posts = ordered_core_ids.filter_map do |id|
            post = localized_by_core[id]
            post.post_core = cores_by_id[id] if post
            post
          end
          countries = Country.select(:id, :slug, :ancestry).to_a
          subregion_ids_by_country = countries.index_with { |c| c.subregion_ids.to_set }
          country_for_locus_id = {}
          countries.each do |country|
            subregion_ids_by_country[country].each { |lid| country_for_locus_id[lid] = country }
          end

          # Single query: distinct (locus_id, month) pairs for this species.
          locus_months = @species.cards.except(:order)
            .distinct
            .pluck(:locus_id, Arel.sql("EXTRACT(month FROM observ_date)::integer"))

          months_by_country = Hash.new { |h, k| h[k] = Set.new }
          locus_months.each do |locus_id, month|
            country = country_for_locus_id[locus_id]
            months_by_country[country.slug] << month if country
          end
          @months = countries.to_h { |c| [c.slug, months_by_country[c.slug].to_a] }

          @grouped_loci = @species.loci.distinct.to_a.group_by do |locus|
            country_for_locus_id[locus.id]&.slug
          end
        else
          @robots = "NOINDEX"
        end
      end
    else
      raise ActiveRecord::RecordNotFound, "Cannot find species `#{id_humanized}` nor its synonyms."
    end
  end

  # GET /species/1/edit
  def edit
    render :form
  end

  # PUT /species/1
  def update
    respond_to do |format|
      if @species.update(params[:species])
        format.html { redirect_to(edit_species_url(@species), notice: "Species was successfully updated.") }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_content }
      end
    end
  end

  # POST /species/search
  def search
    result = Search::PublicSpeciesSearch.new(current_user.searchable_species, params[:term], locale: I18n.locale).find
    render json: result
  end

  def admin_search
    options = params.slice(:limit)
    result = Search::SpeciesSearch.new(current_user.searchable_species, params[:term], options).find
    render json: result
  end

  def review
    @species = Species.where(needs_review: true)
  end

  private

  def find_species
    @species = Species.find_by!(name_sci: Species.humanize(params[:id]))
  end
end
