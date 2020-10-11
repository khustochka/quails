# frozen_string_literal: true

class SpeciesController < ApplicationController

  administrative :except => [:gallery, :show, :search]

  before_action :find_species, only: [:edit, :update]

  # GET /species/admin
  def index
    #TODO : Filter by order, family
    @term = params[:term]
    @species = if @term.present?
                 Search::SpeciesSearchUnweighted.new(Species.all, @term).find
               else
                 Species.order(:index_num).page(params[:page]).per(50)
               end
    @species = @species.preload(:high_level_taxa, :url_synonyms)
    if request.xhr?
      render partial: "species/table", layout: false
    else
      render
    end
  end

  # GET /species
  def gallery
    @species = Species.joins(:image).includes(:image).ordered_by_taxonomy
    @feed = 'photos'
  end

  # GET /species/1
  def show
    id_humanized = Species.humanize(params[:id])
    @species = Species.find_by(name_sci: id_humanized) || UrlSynonym.find_by(name_sci: id_humanized).try(:species)
    if @species
      if params[:id] != @species.to_param
        redirect_to @species, :status => 301
        # TODO: maybe show as a page but set different canonical, NOINDEX. Or redirect but show "redirected from" Like Wikipedia.
      else
        if @species.observations.any?
          @posts = @species.posts.limit(10).merge(current_user.available_posts)
          countries = Country.select(:id, :slug, :ancestry).to_a
          @months = countries.each_with_object({}) do |country, memo|
            memo[country.slug] = @species.cards.except(:order).where(locus_id: country.subregion_ids).distinct.pluck(Arel.sql("EXTRACT(month FROM observ_date)::integer"))
          end
        else
          @robots = 'NOINDEX'
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
        format.html { redirect_to(edit_species_url(@species), notice: 'Species was successfully updated.') }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    result = Search::PublicSpeciesSearch.new(current_user.searchable_species, params[:term]).find
    render json: result
  end

  def admin_search
    options = params.slice(:limit)
    result = Search::SpeciesSearch.new(current_user.searchable_species, params[:term], options).find
    render json: result
  end

  private
  def find_species
    @species = Species.find_by!(name_sci: Species.humanize(params[:id]))
  end
end
