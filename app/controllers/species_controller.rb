class SpeciesController < ApplicationController

  administrative :except => [:gallery, :show, :search]

  before_action :find_species, only: [:edit, :update]

  # GET /species/admin
  def index
    #TODO : Filter by order, family
    @term = params[:term]
    @species = if @term.present?
                 SpeciesSearchUnweighted.new(Species.all, @term).find
               else
                 Species.order(:index_num).page(params[:page]).per(50)
               end
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
        # TODO: set canonical, set NOINDEX
      else
        if @species.observations.any?
          @posts = @species.posts.limit(10).merge(current_user.available_posts)
          countries = Country.select(:id, :slug, :ancestry).to_a
          @months = countries.each_with_object({}) do |country, memo|
            memo[country.slug] = @species.cards.except(:order).where(locus_id: country.subregion_ids).pluck("DISTINCT EXTRACT(month FROM observ_date)::integer")
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
      if @species.update_attributes(params[:species])
        format.html { redirect_to(edit_species_url(@species), notice: 'Species was successfully updated.') }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  def search
    result = SpeciesSearch.new(current_user.searchable_species, params[:term]).find
    render json: result
  end

  # TODO: remove when removing legacy mapping
  def simple_search
    result = Species.where("name_sci ILIKE '#{params[:term]}%' OR name_sci ILIKE '% #{params[:term]}%'").map do |sp|
      {
          value: sp.name_sci,
          label: sp.name_sci,
          id: sp.id
      }
    end
    render json: result
  end

  private
  def find_species
    @species = Species.find_by!(name_sci: Species.humanize(params[:id]))
  end
end
