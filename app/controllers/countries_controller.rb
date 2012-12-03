class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by_slug!(params[:country])

    # FIXME: temporarily use only observations for ukraine, instead of checklist

    country_obs = Observation.select(:species_id).where(locus_id: @country.subregion_ids)
    @species = Species.ordered_by_taxonomy.where("species.id IN (#{country_obs.to_sql})").joins(:image).includes(:image)

    #case @country.slug
    #  when 'ukraine'
    #    @country.checklist.joins(:image).includes(:image)
    #  when 'usa'
    #    country_obs = Observation.select(:species_id).where(locus_id: @country.subregion_ids)
    #    @species = Species.ordered_by_taxonomy.where("species.id IN (#{country_obs.to_sql})").joins(:image).includes(:image)
    #end
  end

  def checklist
    @locus = Country.find_by_slug!(params[:country])
    if @locus.slug == 'ukraine'
      @checklist = @locus.checklist
    else
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{@locus.name_en}"
    end
  end

end
