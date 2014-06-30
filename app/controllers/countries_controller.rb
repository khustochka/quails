class CountriesController < ApplicationController

  def gallery
    @country = Country.quick_find(params[:country])

    case @country.slug
      when 'ukraine'
        @species = @country.checklist([:image, :species])
      when 'usa'
        country_obs = Observation.joins(:card).select(:species_id).where("cards.locus_id" => @country.subregion_ids)
        @species = Species.ordered_by_taxonomy.where("species.id" => country_obs).joins(:image).includes(:image)
      when 'united_kingdom'
        country_obs = Observation.joins(:card).select(:id).where("cards.locus_id" => @country.subregion_ids)
        @images = Image.joins(:observations => :card).
            merge(Observation.where(id: country_obs)).
            preload(:species).
            order('cards.observ_date').basic_order
      else
        raise ActiveRecord::RecordNotFound
    end

  end

end
