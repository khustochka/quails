# frozen_string_literal: true

require "./config/environment"

def calculate(result, therest)
  #puts "-- for the day #{result.size}"
  if therest.empty?
    puts result.map.with_index { |s, i| "#{i+1}. #{s}" }
    exit
  else
    day = therest.first
    if day.is_a? Array
      day.each do |sp_id|
        temprest2 = Marshal.load(Marshal.dump(therest[1..-1]))
        temprest2.each do |d|
          if d.is_a? Array
            d.reject! { |s| s == sp_id }
          end
        end
        next if temprest2.any? { |el| el.empty? }
        cleanup(temprest2)
        #puts "Trying #{SPCS[sp_id]}"
        calculate(result + [SPCS[sp_id]], temprest2)
      end
      false
    else
      temprest2 = Marshal.load(Marshal.dump(therest[1..-1]))
      calculate(result + [day], temprest2)
    end
  end
end

SPCS = Hash[Species.all.map { |s| [s.id, s.name_sci] }]

year = ENV["YEAR"] || Quails::CURRENT_YEAR

obs = MyObservation.joins(:card).
    select("DISTINCT observ_date, species_id").
    where("EXTRACT(year FROM observ_date)::integer = ?", year).
    #where("observ_date <= '2013-01-19'").
    order("observ_date").map { |o| [o.observ_date, o.species_id] }.
    group_by(&:first).values.map { |e| e.map(&:second) }

# p obs.flatten.size

# Use species met only in one day
def cleanup(obs)
  prev_singles = []

  begin
    counts = obs.flatten.inject(Hash.new(0)) { |h, i| h[i] += 1 if i.is_a?(Integer); h }
    singles = counts.to_a.select { |e| e[1] == 1 }.map(&:first) - prev_singles

#  p singles.map {|u| SPCS[u]}

    obs.map! do |day|
      if day.is_a? Array
        cross = day & singles
      end
      if cross.present?
        cross.map { |c| SPCS[c] }.join(", ")
      else
        day
      end
    end

    prev_singles = prev_singles + singles

  end until singles.empty?
end

cleanup(obs)
#puts "Start"
# p obs.flatten.size

calculate([], obs)
