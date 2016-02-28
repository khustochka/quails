class LegacySpeciesController < ApplicationController

  administrative

  before_action :find_species, only: [:edit, :update, :review]

  # GET /species/admin
  def index
    @species = LegacySpecies.ordered_by_taxonomy.extend(SpeciesArray)
  end

  # GET /species
  def gallery
    @species = Species.joins(:image).includes(:image).ordered_by_taxonomy
    @feed = 'photos'
  end

  # GET /species/1
  def show
    id_humanized = LegacySpecies.humanize(params[:id])
    @species = LegacySpecies.find_by(name_sci: id_humanized)
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
      raise ActiveRecord::RecordNotFound, "Cannot find #{id_humanized}"
    end
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

  # GET /species/1/review
  # def review
  #   @books = @species.taxa.joins(:book).includes(:book).order(:book_id).index_by(&:book)
  #
  #   if @species.code.present?
  #     local_opts = YAML.load_file('config/local.yml')
  #     folder = local_opts['repo']
  #     leg = File.open("#{folder}/legacy/seed_data.yml", encoding: 'windows-1251:utf-8') do |f|
  #       YAML.load(f.read)
  #     end
  #     spcs = leg['species']
  #     cols = spcs['columns']
  #     col = cols.index('sp_id')
  #     legacy = spcs['records'].find { |rec| rec[col] == @species.code }
  #     if legacy
  #       legacy = Hash[cols.zip(legacy)]
  #       @legacy = Struct.
  #           new(:name_sci, :name_en, :name_ru, :name_uk).
  #           new(legacy['sp_la'], legacy['sp_en'], legacy['sp_ru'], legacy['sp_uk'])
  #     end
  #   end
  #   obs = Observation.select(:species_id)
  #   # Book with id=1 is Fesenko-Bokotey
  #   ukr = Taxon.where(book_id: 1).select(:species_id)
  #   @next_species = Species.
  #       where("id in (#{obs.to_sql}) OR id IN (#{ukr.to_sql})").
  #       where("index_num > #{@species.index_num}").
  #       where("NOT reviewed").
  #       order(:index_num).first
  # end

  def mapping
    fesenko = Book.find(1)
    @legacy_species =
        LegacySpecies.
            where("id IN (?) OR id IN (?)", Observation.select(:legacy_species_id), fesenko.legacy_taxa.select(:species_id)).
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
