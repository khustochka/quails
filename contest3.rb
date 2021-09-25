# frozen_string_literal: true

require "./config/environment"

class MaxDateReached < Exception

end

SPCS = Hash[Species.all.map { |s| [s.id, s.name_sci] }]

year = (ENV["YEAR"] || Quails::CURRENT_YEAR).to_i

$obs = MyObservation.joins(:card).
    select("DISTINCT observ_date, species_id").
    where("EXTRACT(year FROM observ_date)::integer = ?", year).
    order("observ_date").group_by(&:observ_date)

$obs.each do |d, el|
  $obs[d] = el.map(&:species_id).uniq
end

$max_date = $obs.keys.max

def calculate(date, result, the_rest)
  depth = result.size
  if $deepest < date - 1
    puts "Deepest #{date - 1}"
    puts result.map.with_index { |s, i| "#{i + 1}. #{SPCS[s]}" }
    puts "\n"
    $deepest = date - 1
    $best = result
  end
  if $deepest == $max_date
    raise MaxDateReached
  end
  if the_rest[date].nil?
    return
  end
  left = the_rest[date] - result
  if left.empty?
    # puts "Last day reached #{date - 1}"
  else
    total = left.size
    left.each_with_index do |sp, index|
      # puts ("--" * depth) + " trying #{index + 1} of #{total}"
      new_rest = {}
      the_rest.each do |day, list|
        if day > date
          new_rest[day] = list - [sp]
        end
      end
      # Cutoff
      empty_date = new_rest.find {|d, l| l.empty?}
      if empty_date
        if empty_date.first <= $deepest
          return
        end
      end
      calculate(date + 1, result + [sp], new_rest)
    end
  end
end

# Use species met only in one day
def cleanup(obs)
  used_singles = []
  begin
    counts = obs.values.flatten.inject(Hash.new(0)) { |h, i| h[i] += 1 if i.is_a?(Integer); h }
    singles = counts.to_a.select { |e| e[1] == 1 }.map(&:first) - used_singles

    if singles.present?

      obs.each do |day, sps|
        cross = sps & singles
        if cross.present?
          used_singles.concat(cross)
          obs[day] = [cross.first]
        end
      end
    end

  end until singles.empty?
end

cleanup($obs)

jan_1 = Date.new(year, 1, 1)

$deepest = jan_1 - 1

begin
  calculate(jan_1, [], $obs.dup)
rescue MaxDateReached
end

# puts $best.map.with_index { |s, i| "#{i+1}. #{SPCS[s]}" }
