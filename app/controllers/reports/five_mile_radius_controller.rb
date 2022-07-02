# frozen_string_literal: true

module Reports
  class FiveMileRadiusController < ApplicationController
    administrative

    def index
      candidates_5mr = Rails.cache.read("5mr/candidates") || []
      candidates_removal = Rails.cache.read("5mr/removal") || []
      loci_ids = (candidates_5mr + candidates_removal).pluck(:locus_id)
      loci = Locus.where(id: loci_ids).index_by(&:id)
      @candidates_5mr = candidates_5mr.
        select { |rec| !loci[rec[:locus_id]].five_mile_radius }.
        each { |rec| rec[:locus] = loci[rec[:locus_id]] }.
        sort_by { |e| e[:distance] }
      @candidates_removal = candidates_removal.
        select { |rec| loci[rec[:locus_id]].five_mile_radius }.
        each { |rec| rec[:locus] = loci[rec[:locus_id]] }.
        sort_by { |e| e[:distance] }
    end

    def update
      locs = params[:locus_id]
      approve = if params[:commit] == "Confirm"
        true
      elsif params[:commit] == "Remove"
        false
      else
        raise "Invalid commit action"
      end
      Locus.where(id: locs).update_all(five_mile_radius: approve)
      CacheKey.lifelist.invalidate
      redirect_to reports_five_mile_radius_path
    end
  end
end
