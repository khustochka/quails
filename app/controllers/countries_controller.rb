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
    #@checklist = @locus.checklist
    # FIXME: temporarily use Fesenko-Bokotey Book
    if @locus.slug == 'ukraine'
      @checklist = Book.find_by_slug('fesenko-bokotej').taxa.extend(SpeciesArray)
    else
      raise "Incorrect option"
    end
  end

end