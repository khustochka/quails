class LifelistController < ApplicationController

  # GET /lifelist
  # GET /lifelist.xml
  def lifelist
    #extended_params = params.dup
    #extended_params.merge!(:loc_ids => Locus.select(:id).find_by_code!(params[:locus]).get_subregions) if params[:locus]
    #@years = Observation.years(extended_params)
    #
    ##raw_posts = @lifelist.map {|ob| [ob.first_post, ob.last_post]}.flatten.uniq.compact
    ##@posts = Hash[SessionAwarePost().where(:id => raw_posts).map {|rec| [rec.id.to_s, rec] }]
    #
    #@entries = Observation.lifelist
    #
    ##post_ids = Observation.select("DISTINCT post_id").
    ##    where("(species_id, observ_date) IN (#{@entries.map{|o| "(#{o.species_id},'#{o.aggr_value}')"}.join(',')})").all
    #
    #respond_to do |format|
    #  format.html
    #  format.xml { render :xml => @entries }
    #end

    render :inline => '<h2>Lifelist is work-in-progress</h2>', :layout => 'public'
  end

  def count
    @species = Species.lifelist_by_count.all
  end
end