# frozen_string_literal: true

class YearContest
  def initialize(year: ENV["YEAR"] || Quails::CURRENT_YEAR, debug: false)
    @year = year
    @debug = debug
  end

  def interactive
    # interactive is incompatible with debug
    @debug = false
    @best_so_far = []
    result = run(interactive: true)
    puts "\n\n"
    puts generate_output(result)
  rescue Interrupt
    puts "\n\nUnfinished. Best so far:\n\n"
    puts generate_output(@best_so_far)
  end

  def run(interactive: false)
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

    run_on(obs_arr, interactive: interactive)
  end

  def run_on(list, interactive: false)
    find_best(list, 0, { day: 0, chain_so_far: [], best_so_far: [], start_time: Time.zone.now }, interactive: interactive) || []
  end

  def output
    result = run
    generate_output(result)
  end

  private

  def fetch_species(sp_ids)
    Hash[Species.where(id: sp_ids).map { |s| [s.id, s.name_sci] }]
  end

  def find_best(list, cur_best, dbg_data, interactive: false)
    if list.empty?
      false
    else
      find_best_nonempty(list, cur_best, dbg_data, interactive: interactive)
    end
  end

  def find_best_nonempty(list, cur_best, dbg_data, interactive: false)
    day = dbg_data[:day] + 1
    chain_so_far = dbg_data[:chain_so_far]
    best_so_far = dbg_data[:best_so_far]
    start_time = dbg_data[:start_time]

    interactive_output(best_so_far, start_time) if interactive

    debg("Trying Day #{day}, chain so far [#{chain_so_far.join(", ")}], best_so_far {#{best_so_far.join(", ")}} (size #{best_so_far.size})", day)

    list2 = list.dup

    time_to_exit = true

    loop do
      time_to_exit = true

      # Trim the list
      list3 = trim_list(list2)
      return false if no_gain?(list3, cur_best)

      time_to_exit = list3 == list2
      # ====================

      list2 = list3
      # Cut off by the number of species (e.g. if there are 10 days ahead but only 8 species)
      list3 = cutoff_by_species(list2)
      return false if no_gain?(list3, cur_best)

      time_to_exit = list3 == list2
      # ====================

      # Commented this, because it does not seem to give material gain (tested on long running data)
      # list2 = list3
      # # If a day has only one species, and this species is not met before, it can be removed from all further sightings
      # list3 = process_single_species_days(list2)
      # return false if no_gain?(list3, cur_best)

      # time_to_exit &&= list3 == list2
      # # ====================

      list2 = list3
      # If a day has a species that was not met before or after, all other species can be removed from this day
      list3 = process_unique_species_days(list2)
      return false if no_gain?(list3, cur_best)

      time_to_exit &&= list3 == list2
      # ====================

      list2 = list3
      break if time_to_exit
    end

    new_best_so_far = best_so_far
    new_best = 0
    best_res = [list2.first.first]
    list2.first.each do |selected_species|
      new_best_so_far = if (candidate = chain_so_far + best_res).size > new_best_so_far.size
        candidate
      else
        new_best_so_far
      end

      debg("= Selected Sp #{selected_species} on day #{day}", day)
      new_list = list2[1..].map {|sps| sps.reject {|sp| sp == selected_species}}
      @best_so_far = new_best_so_far
      result = find_best(new_list, new_best, { day: day, chain_so_far: chain_so_far + [selected_species], best_so_far: new_best_so_far, start_time: start_time }, interactive: interactive)
      next if result.blank? || result.size <= new_best

      debg(" > Good result received: length #{result.size} (#{result.join(", ")})", day)
      new_best = result.size
      best_res = [selected_species] + result
    end
    best_res
  end

  def trim_list(list)
    list.take_while(&:present?)
  end

  def process_single_species_days(list)
    seen_spcs = []
    spcs_to_del = []
    list.map do |spcs|
      new_spcs = spcs - spcs_to_del
      if new_spcs.size == 1
        if !new_spcs.first.in?(seen_spcs)
          spcs_to_del.push(new_spcs.first)
        end
      else
        seen_spcs += new_spcs
        seen_spcs.uniq!
      end
      new_spcs
    end
  end

  def process_unique_species_days(list)
    unique_species = list.flatten.tally.select {|_, val| val == 1}.map(&:first)
    list.map do |spcs|
      if (sp = unique_species.find {|el| el.in?(spcs)})
        [sp]
      else
        spcs
      end
    end
  end

  def cutoff_by_species(list)
    have_species = []
    list.take_while.with_index do |sps, i|
      have_species += sps
      have_species.uniq!
      # Need to have enough species to cover all days
      have_species.size >= i + 1
    end
  end

  def no_gain?(list, cur_best)
    list.size <= cur_best || list.flatten.uniq.size <= cur_best
  end

  def debg(text, level)
    if @debug
      Rails.logger.debug((" " * 2 * (level - 1)) + text)
    end
  end

  def generate_output(result)
    if result.blank?
      "No species"
    else
      species = fetch_species(result)
      result.map.with_index { |s, i| "#{i + 1}. #{species[s]}" }
    end
  end

  def interactive_output(list, start_time)
    duration = Time.zone.now - start_time
    str = "%02d:%02d:%06.3f" % divide_seconds(duration)
    print("#{@year} * Time elapsed: #{str} * Best result so far: #{"%3d" % list.size}\r")
  end

  def divide_seconds(seconds)
    hours, seconds   = seconds.divmod(3600)
    minutes, seconds = seconds.divmod(60)

    [hours, minutes, seconds]
  end
end
