class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by_slug!(params[:country])
    @species =
        case @country.slug
          when 'ukraine'
            @country.checklist.joins(:image).includes(:image)
          when 'usa'
            Species.ordered_by_taxonomy.joins(:image).includes(:image).
                includes(:observations).where("observations.locus_id" => @country.subregion_ids)

        end
  end

  def checklist
    @locus = Country.find_by_slug!(params[:country])
    @checklist = @locus.checklist
  end

end