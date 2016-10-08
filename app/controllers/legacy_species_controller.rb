class LegacySpeciesController < ApplicationController

  administrative

  before_action :find_species, only: [:edit, :update]

  # GET /species/admin
  def index
    @species = LegacySpecies.ordered_by_taxonomy.extend(SpeciesArray)
  end

  # GET /species/1/edit
  def edit
    render :form
  end

  # PUT /species/1
  def update

    respond_to do |format|
      if @species.update_attributes(params[:legacy_species])
        format.html { redirect_to(@species, notice: 'Species was successfully updated.') }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /species
  def create

    @species = Species.new(params[:species])
    respond_to do |format|
      if @species.save
        format.html { redirect_to(@species, notice: 'Species was successfully created.') }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
    end
  end

  def mapping
    fesenko = Book.find(1)
    rx = /\{\{(?:([^@#\\^&][^\}]*?)\|)?([^@#\\^&][^\}]*?)(\|en)?\}\}/
    in_posts_codes = Post.all.map { |p| p.text.scan(rx).map(&:second) }.inject(:+).uniq
    in_posts_sps = LegacySpecies.where("code IN (?) OR name_sci IN (?)", in_posts_codes, in_posts_codes).pluck(:id)

    full = LegacySpecies.
        where("id IN (?) OR id IN (?) OR id IN (?)",
              Observation.select(:legacy_species_id),
              fesenko.legacy_taxa.select(:species_id),
              in_posts_sps)
    @undecided = full.where(species_id: nil)

    @legacy_species =
        if @undecided.present?
          @undecided
        else
          full
        end
    @legacy_species = @legacy_species.
        order(:index_num).
        preload(:species).
        page(params[:page])
  end

  def search
    result = SpeciesSearch.new(current_user.searchable_species, params[:term]).find
    render json: result
  end

  private
  def find_species
    @species = LegacySpecies.find_by!(name_sci: LegacySpecies.humanize(params[:id]))
  end
end
