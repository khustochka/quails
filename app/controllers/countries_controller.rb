class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by!(slug: params[:country])

    @thumbs = case @country.slug
      when 'ukraine'
        @country.checklist([:image])
#      when 'usa'
#        country_sps = Observation.joins(:card).select(:species_id).where("cards.locus_id" => @country.subregion_ids)
#        Species.ordered_by_taxonomy.where("species.id" => country_sps).joins(:image).includes(:image)
      when 'united_kingdom', 'usa', 'canada'
        Image.joins(:observations => :card).
            select("DISTINCT media.*, cards.observ_date").
            where("cards.locus_id" => @country.subregion_ids).
            preload(:species).
            order('cards.observ_date').basic_order
      else
        raise ActiveRecord::RecordNotFound
    end

  end

end
