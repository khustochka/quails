class CountriesController < ApplicationController

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

end
