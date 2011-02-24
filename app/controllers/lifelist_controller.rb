class LifelistController < ApplicationController

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    extended_params = params.dup
    extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]

    @lifelist = Species.lifelist(extended_params).all
    raw_posts = Observation.lifers_posts(@lifelist).select('species_id, observ_date, filtered_posts.code, filtered_posts.face_date').\
        joins("INNER JOIN (#{SessionAwarePost().select('id, face_date, code').to_sql}) AS filtered_posts ON observations.post_id=filtered_posts.id").all
    @posts = raw_posts.inject({}) do |memo, rec|
      memo[rec.species_id] ||= {}
      memo[rec.species_id][rec.observ_date.to_s] ||= Post.new(:code => rec.code, :face_date => rec.face_date)
      memo
    end
    @years = Observation.years(extended_params)

    respond_to do |format|
      format.html
      format.xml { render :xml => @species }
    end
  end
end
