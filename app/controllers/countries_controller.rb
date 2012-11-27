class CountriesController < ApplicationController

  def gallery
    @country = Country.find_by_slug!(params[:country])

    # FIXME: temporarily use only observations for ukraine, instead of checklist
    @species = Species.ordered_by_taxonomy.joins(:image).includes(:image).
        includes(:observations).where("observations.locus_id" => @country.subregion_ids)

    #case @country.slug
    #  when 'ukraine'
    #    @country.checklist.joins(:image).includes(:image)
    #  when 'usa'
    #    Species.ordered_by_taxonomy.joins(:image).includes(:image).
    #        includes(:observations).where("observations.locus_id" => @country.subregion_ids)
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