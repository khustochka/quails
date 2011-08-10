class LifelistController < ApplicationController

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]
    @years = Observation.years(extended_params)

    #@lifelist = Species.lifelist(extended_params)
    #raw_posts = @lifelist.map {|ob| [ob.first_post, ob.last_post]}.flatten.uniq.compact
    #@posts = Hash[SessionAwarePost().where(:id => raw_posts).map {|rec| [rec.id.to_s, rec] }]

    @entries = Species.identified.select('species.id, name_sci, name_ru, name_en, name_uk, MIN(observ_date) as aggr_value').
        joins(:observations).
        where('observations.mine' => true).group('species.id, name_sci, name_ru, name_en, name_uk').
        reorder('aggr_value DESC').all

    respond_to do |format|
      format.html
      format.xml { render :xml => @entries }
    end
  end
end