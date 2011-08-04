class ResearchController < ApplicationController

  require_http_auth

  layout 'admin'

  def index
  end

  def more_than_year
    sort_col = params[:sort].try(:to_sym) || :date2
    period = params[:period].try(:to_i) || 365
    @list = Species.includes(:observations).inject([]) do |collection, sp|
      prev = nil
      obs = sp.observations.inject([]) do |memo, ob|
        unless prev.nil?
          memo.push([prev.observ_date, ob.observ_date]) if (ob.observ_date - prev.observ_date) >= period
        end
        prev = ob
        memo
      end
      obs.each do |date1, date2|
        collection.push(
                {:sp => sp,
                 :date1 => date1,
                 :date2 => date2,
                 :days => date2 - date1}
        )
      end
      collection
    end.sort { |a, b| b[sort_col] <=> a[sort_col] }
  end
end
