desc 'Tasks to find out something interesting'
namespace :discover do

  desc 'Show species with more than a year between observations'
  task :more_than_year => :environment do
    list = Species.includes(:observations).inject([]) do |collection, sp|
      prev = nil
      obs = sp.observations.inject([]) do |memo, ob|
        unless prev.nil?
          memo.push([prev.observ_date, ob.observ_date]) if (ob.observ_date - prev.observ_date) >= 365
        end
        prev = ob
        memo
      end
      unless obs.empty?
        label = "#{sp.name_sci} / #{sp.name_ru}"
        obs.each { |el| collection.push({:date => el[1], :text => "#{label}:  #{el[0]} - #{el[1]} (#{el[1] - el[0]})"}) }
      end
      collection
    end
    list.sort { |a, b| a[:date] <=> b[:date] }.each { |el| puts el[:text] }
  end

end