require './config/environment'

def calculate(result, therest)
  #puts "-- for the day #{result.size}"
  if therest.empty?
    puts result.map.with_index { |s, i| "#{i+1}. #{SPCS[s]}" }
    exit
  else
    day = therest.first
    day.each do |sp_id|
      temprest2 = Marshal.load(Marshal.dump(therest[1..-1]))
      temprest2.each do |d|
        d.reject! { |s| s == sp_id }
      end
      next if temprest2.any? { |el| el.empty? }
      #puts "Trying #{SPCS[sp_id]}"
      calculate(result + [sp_id], temprest2)
    end
    return false
  end
end

SPCS = Hash[Species.all.map { |s| [s.id, s.name_sci] }]

obs = MyObservation.
    select('DISTINCT observ_date, species_id').
    where('EXTRACT(year FROM observ_date) = 2013').
    #where("observ_date <= '2013-01-19'").
    order(:observ_date).map { |o| [o.observ_date, o.species_id] }.
    group_by(&:first).values.map { |e| e.map(&:second) }

# p obs.flatten.size

# Use species met only in one day

prev_singles = []

begin
  counts = obs.flatten.inject(Hash.new(0)) { |h, i| h[i] += 1; h }
  singles = counts.to_a.select { |e| e[1] == 1 }.map(&:first) - prev_singles

#  p singles.map {|u| SPCS[u]}

  obs.map! do |day|
    cross = day & singles
    if cross.present?
      cross
    else
      day
    end
  end

  prev_singles = prev_singles + singles

end until singles.empty?

# p obs.flatten.size

calculate([], obs)
