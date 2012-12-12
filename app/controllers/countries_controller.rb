class CountriesController < ApplicationController

  administrative except: [:gallery, :checklist]

  def gallery
    @country = Country.find_by_slug!(params[:country])

    @species =
        case @country.slug
          when 'ukraine'
            @country.checklist(:image)
          when 'usa'
            country_obs = Observation.select(:species_id).where(locus_id: @country.subregion_ids)
            Species.ordered_by_taxonomy.where("species.id IN (#{country_obs.to_sql})").joins(:image).includes(:image)
          else
            raise ActiveRecord::RecordNotFound
        end
  end

  def checklist
    fetch_checklist
    render @country.slug
  end

  def checklist_edit
    fetch_checklist
    @edit = true
    render @country.slug
  end

  private
  def fetch_checklist
    @country = Country.find_by_slug!(params[:country])
    if @country.slug == 'ukraine'
      @checklist = @country.checklist
    else
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{@country.name_en}"
    end
  end

end
