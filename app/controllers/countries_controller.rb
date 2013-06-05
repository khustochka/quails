class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by_slug!(params[:country])
    @max_width = params[:width].try(&:to_i)

    @species = case @country.slug
      when 'ukraine'
        @country.checklist(:image)
      when 'usa'
        country_obs = Observation.joins(:card).select(:species_id).where("cards.locus_id" => @country.subregion_ids)
        @species = Species.ordered_by_taxonomy.where("species.id" => country_obs).joins(:image).includes(:image)
      else
        raise ActiveRecord::RecordNotFound
    end

    if request.xhr?
      render 'countries/gallery/_justified_ukraine', layout: false
    else
      render 'gallery'
    end

  end

end
