class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by_slug!(params[:country])

    @species =
        case @country.slug
          when 'ukraine'
            @country.checklist(:image)
          when 'usa'
            country_obs = Observation.joins(:card).select(:species_id).where("cards.locus_id" => @country.subregion_ids)
            Species.ordered_by_taxonomy.where("species.id" => country_obs).joins(:image).includes(:image)
          else
            raise ActiveRecord::RecordNotFound
        end
  end

end
