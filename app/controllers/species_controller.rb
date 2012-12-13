class SpeciesController < ApplicationController

  administrative :except => [:gallery, :show]

  before_filter :find_species, only: [:edit, :update, :review]

  # GET /species/admin
  def index
    @species = Species.ordered_by_taxonomy.extend(SpeciesArray)

    @observed = Species.where("id IN (#{Observation.select(:species_id).to_sql})")
    @obs_not_reviewed = @observed.where("NOT reviewed")

    fesenko = Book.find(1)
    @ukrainian = fesenko.taxa
    @ukr_not_reviewed = Species.where("id IN (#{fesenko.taxa.select(:species_id).to_sql})").where("NOT reviewed")
  end

  # GET /species
  def gallery
    @species = Species.joins(:image).includes(:image).ordered_by_taxonomy
    @feed = 'photos'
  end

  # GET /species/1
  def show
    id_humanized = params[:id].sp_humanize
    @species = Species.find_by_name_sci(id_humanized) || Taxon.find_by_name_sci!(id_humanized).species
    if @species
      if params[:id] != @species.to_param
        #redirect_to @species, :status => 301
        # TODO: set canonical, set NOCACHE, NOINDEX
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
    params[:species].delete(:code) if params[:species][:code].blank?
    if @species.update_attributes(params[:species])
      redirect_to(@species, :notice => 'Species was successfully updated.')
    else
      render :form
    end
  end

  # GET /species/1/review
  def review
    @books = @species.taxa.joins(:book).includes(:book).order(:book_id).index_by(&:book)

    if @species.code.present?
      local_opts = YAML.load_file('config/local.yml')
      folder = local_opts['repo']
      leg = File.open("#{folder}/legacy/seed_data.yml", encoding: 'windows-1251:utf-8') do |f|
        YAML.load(f.read)
      end
      spcs = leg['species']
      cols = spcs['columns']
      col = cols.index('sp_id')
      legacy = spcs['records'].find { |rec| rec[col] == @species.code }
      legacy = Hash[ cols.zip(legacy) ]
      @legacy = Struct.
          new(:name_sci, :name_en, :name_ru, :name_uk).
          new(legacy['sp_la'], legacy['sp_en'], legacy['sp_ru'], legacy['sp_uk'])
    end
  end

  private
  def find_species
    @species = Species.find_by_name_sci!(params[:id].sp_humanize)
  end
end
