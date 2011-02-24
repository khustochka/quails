class LifelistController < ApplicationController

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]

    @lifelist = Species.lifelist(extended_params).all
#    @posts    = SessionAwarePost().where(:id => @lifelist.map(&:post_id)).inject({}) { |memo, el| memo.merge({el.id => el}) }
    @years    = Observation.years(extended_params)

    respond_to do |format|
      format.html
      format.xml { render :xml => @species }
    end
  end
end