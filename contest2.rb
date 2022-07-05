# frozen_string_literal: true

require "./config/environment"

$deepest = 0

def calculate(therest)
  current_day = $year_size - therest.size + 1
  if current_day > $deepest
    puts "\n---------- Deepest day #{$deepest += 1}"
  end
  print "Current day %3d\r" % current_day
  day = therest.first
  longest = []
  if therest.take($deepest - current_day + 1).any?(&:empty?)
    longest = if day.is_a? Array
      [day.map { |c| SPCS[c] }.join(", ")]
    else
      [day]
    end
  else
    if day.is_a? Array
      day.each do |sp_id|
        temprest2 = Marshal.load(Marshal.dump(therest[1..-1]))
        temprest2.each do |d|
          if d.is_a? Array
            d.reject! { |s| s == sp_id }
          end
        end
        if temprest2.take($deepest - current_day).any?(&:empty?)
          # puts "Cutoff"
          next
        end
        cleanup(temprest2)
        # puts "Trying #{SPCS[sp_id]}"
        result = if temprest2[0].blank?
          [SPCS[sp_id]]
        else
          [SPCS[sp_id]] + calculate(temprest2)
        end
        if result.size > longest.size
          longest = result
        end
      end
    else
      temprest2 = Marshal.load(Marshal.dump(therest[1..-1]))
      longest = [day] + calculate(temprest2)
    end
  end
  longest
end

SPCS = Hash[Species.all.map { |s| [s.id, s.name_sci] }]

year = ENV["YEAR"] || Quails::CURRENT_YEAR

obs_rel = MyObservation.joins(:card).
  where("EXTRACT(year FROM observ_date)::integer = ?", year).
  order("observ_date").
  distinct.
  pluck("observ_date, species_id").
  group_by(&:first).transform_values { |v| v.map(&:second) }

obs = []

obs_rel.each do |date, obss|
  obs[date.yday - 1] = obss
end

# p obs.flatten.size

$year_size = obs.size

# Use species met only in one day
def cleanup(obs)
  obs = obs.take_while(&:present?)
  begin
    counts = obs.flatten.inject(Hash.new(0)) { |h, i| h[i] += 1 if i.is_a?(Integer); h }
    singles = counts.to_a.select { |e| e[1] == 1 }.map(&:first)

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

  end until singles.empty?
end

cleanup(obs)
# puts "Start"
# p obs.size

result = calculate(obs)

puts result.map.with_index { |s, i| "#{i + 1}. #{s}" }
