class Reports::FiveMileRadiusController < ApplicationController

  administrative

  def index
    candidates_5mr = Rails.cache.read("5mr/candidates") || []
    candidates_removal = Rails.cache.read("5mr/removal") || []
    loci_ids = (candidates_5mr + candidates_removal).map {|record| record[:locus_id]}
    loci = Locus.where(id: loci_ids).index_by(&:id)
    @candidates_5mr = candidates_5mr.each {|rec| rec[:locus] = loci[rec[:locus_id]]}.sort_by {|e| e[:distance]}
    @candidates_removal = candidates_removal.each {|rec| rec[:locus] = loci[rec[:locus_id]]}.sort_by {|e| e[:distance]}
  end
end
