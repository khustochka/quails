class SpeciesController < ApplicationController

  cache_sweeper :gallery_sweeper

  administrative :except => [:gallery, :show]

  before_filter :find_species, only: [:edit, :update, :review]

  # GET /species/admin
  def index
    @species = Species.ordered_by_taxonomy.extend(SpeciesArray)

    @observed = Species.where(id: Observation.select(:species_id))
    @obs_not_reviewed = @observed.where("NOT reviewed")

    fesenko = Book.find(1)
    @ukrainian = fesenko.taxa
    @ukr_not_reviewed = Species.where(id: fesenko.taxa.select(:species_id)).where("NOT reviewed")

    @reviewed = Species.where("reviewed")
  end

  # GET /species
  def gallery
    @species = Species.joins(:image).includes(:image).ordered_by_taxonomy
    @feed = 'photos'
    @thumbnail_for_multiple_species = Image.multiple_species.first
  end

  # GET /species/1
  def show
    id_humanized = Species.humanize(params[:id])
    @species = Species.find_by_name_sci(id_humanized) || Taxon.find_by_name_sci!(id_humanized).species
    if @species
      if params[:id] != @species.to_param
        redirect_to @species, :status => 301
        # TODO: set canonical, set NOINDEX
      else
        if @species.observations.any?
          @posts = @species.posts.limit(10).merge(current_user.available_posts)
        else
          @robots = 'NOINDEX'
        end
        @months = @species.observations.except(:order).pluck("DISTINCT EXTRACT(month FROM observ_date)")
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
    # if code is not provided, should not remove it
    # if code is empty string, should remove it
    params[:species][:code] = nil if params[:species][:code] == ''

    respond_to do |format|
      if @species.update_attributes(params[:species])
        format.html { redirect_to(@species, notice: 'Species was successfully updated.') }
        format.json { render json: @species }
      else
        format.html { render :form }
        format.json { render json: @species.errors, status: :unprocessable_entity }
      end
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
      if legacy
        legacy = Hash[cols.zip(legacy)]
        @legacy = Struct.
            new(:name_sci, :name_en, :name_ru, :name_uk).
            new(legacy['sp_la'], legacy['sp_en'], legacy['sp_ru'], legacy['sp_uk'])
      end
    end
    obs = Observation.select(:species_id)
    ukr = Book.find(1).taxa.select(:species_id)
    @next_species = Species.
        where("id in (#{obs.to_sql}) OR id IN (#{ukr.to_sql})").
        where("index_num > #{@species.index_num}").
        where("NOT reviewed").
        order(:index_num).first
  end

  private
  def find_species
    @species = Species.find_by_name_sci!(Species.humanize(params[:id]))
  end
end
