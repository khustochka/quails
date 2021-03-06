# frozen_string_literal: true

require "./config/environment"

SPCS = Hash[Species.all.map { |s| [s.id, s.name_sci] }]

YEAR = ENV["YEAR"] || Quails::CURRENT_YEAR

obs = MyObservation.joins(:card).
    where("EXTRACT(year FROM observ_date)::integer = ?", YEAR).
    order("observ_date").
    distinct.
    pluck("observ_date, species_id").
    group_by(&:first).transform_values { |v| v.map(&:second) }

obs_arr = []

obs.each do |date, obss|
  obs_arr[date.yday-1] = obss
end

def num_days(obs)
  obs.size
end

def num_species(obs)
  obs.flat_map.uniq.size
end

def report(str, obs)
  puts "\n\n"
  puts str
  puts "- Days: #{num_days(obs)}"
  puts "- Species: #{num_species(obs)}"
end

report "Starting with: ", obs_arr

# If there are any empty days, we cannot proceed past it.
def strip_at_empty_day(obs)
  obs.take_while(&:present?)
end

# If a species is seen only once, it belongs to this day. Merge lifers?
def extract_singles(obs)
  obs
end

# If only 1 species seen some day, remove it from all LATER days? Or this will be done automatically later?
def one_sp_day(obs)
  [obs, false]
end

def strip_not_enough_species(obs)
  obs2 = extract_singles(obs)

  while num_days(obs2) > num_species(obs2)
    obs2 = obs2[0..num_species(obs2)-1]
    obs2 = extract_singles(obs2)
  end

  obs2
end

any_changed = []

obs_arr = strip_at_empty_day(obs_arr)
obs_arr = strip_not_enough_species(obs_arr)

report "After recalc:", obs_arr
