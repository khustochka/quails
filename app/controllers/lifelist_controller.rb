class LifelistController < ApplicationController

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]

    @lifelist = Species.lifelist(extended_params)
    raw_posts = @lifelist.map {|ob| [ob.first_post, ob.last_post]}.flatten.uniq.compact
    @posts = Hash[SessionAwarePost().where(:id => raw_posts).map {|rec| [rec.id.to_s, rec] }]
    @years = Observation.years(extended_params)

    respond_to do |format|
      format.html
      format.xml { render :xml => @species }
    end
  end
end