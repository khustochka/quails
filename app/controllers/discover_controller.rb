class DiscoverController < ApplicationController
  def index
  end

  def more_than_year
    @list = Species.includes(:observations).inject([]) do |collection, sp|
      prev = nil
      obs = sp.observations.inject([]) do |memo, ob|
        unless prev.nil?
          memo.push([prev.observ_date, ob.observ_date]) if (ob.observ_date - prev.observ_date) >= 365
        end
        prev = ob
        memo
      end
      obs.each do |el|
        collection.push(
                {:sp => sp,
                 :date1 => el[0],
                 :date2 => el[1],
                 :days => el[1] - el[0]}
        )
      end
      collection
    end.sort { |a, b| b[:date2] <=> a[:date2] }
  end
end
