# frozen_string_literal: true

class YearContest
  def initialize(year: ENV["YEAR"] || Quails::CURRENT_YEAR, debug: false)
    @year = year
    @debug = debug
  end

  def run
    obs = MyObservation.joins(:card)
      .where("EXTRACT(year FROM observ_date)::integer = ?", @year)
      .order("observ_date")
      .distinct
      .pluck("observ_date, species_id")
      .group_by(&:first)
      .transform_values { |v| v.map(&:second) }

    obs_arr = []
    # This is to properly fill in days without species
    obs.each do |date, obss|
      obs_arr[date.yday - 1] = obss
    end

    # binding.break

    run_on(obs_arr)
  end

  def run_on(list)
    find_best(list, 0, { day: 1 }) || []
  end

  def output
    result = run
    if result.blank?
      "No species"
    else
      species = fetch_species(result)
      result.map.with_index { |s, i| "#{i + 1}. #{species[s]}" }
    end
  end

  private

  def fetch_species(sp_ids)
    Hash[Species.where(id: sp_ids).map { |s| [s.id, s.name_sci] }]
  end

  def find_best(list, cur_best, dbg_data)
    if list.empty?
      false
    else
      find_best_nonempty(list, cur_best, dbg_data)
    end
  end

  def find_best_nonempty(list, cur_best, dbg_data)
    day = dbg_data[:day] + 1

    debg("Starting Day #{day}", day)

    list2 = list.dup

    list3 = trim_list(list2)
    return false if no_gain?(list3, cur_best)

    first_species = list3.first
    rest_species = list3[1..].flatten.uniq

    if (uniq_first_sp = first_species.find {|sp| !sp.in?(rest_species)})
      list3[0] = [uniq_first_sp]
    end

    new_best = 0
    best_res = [list3.first.first]
    list3.first.each do |selected_species|
      # binding.break

      debg("= Selected Sp #{selected_species} on day #{day}", day)
      new_list = list3[1..].map {|sps| sps.reject {|sp| sp == selected_species}}
      result = find_best(new_list, new_best, { day: day })
      next if result.blank? || result.size <= new_best

      debg("= Good result received: length #{result.size} (#{result.join(", ")})", day)
      new_best = result.size
      best_res = [selected_species] + result
    end
    best_res
  end

  def trim_list(list)
    list.take_while(&:present?)
  end

  def no_gain?(list, cur_best)
    list.size <= cur_best || list.flatten.uniq.size <= cur_best
  end

  def debg(text, level)
    if @debug
      Rails.logger.debug((" " * 2 * (level - 1)) + text)
    end
  end
end
