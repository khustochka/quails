# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  @base = MyObservation.refine({}).joins(:card)
  @dates =

  Benchmark.ips do |bench|
    bench.report("preselect") do
      @base.select(
          "first_value(observations.id)
          OVER (PARTITION BY species_id
          ORDER BY observ_date ASC, to_timestamp(start_time, 'HH24:MI') ASC NULLS LAST)"
      ).
          where("(species_id, observ_date) IN
                (select species_id, MAX(observ_date)
                  from observations join cards on card_id=cards.id
                group by species_id)").
          to_a
    end

    bench.report("full") do
      @base.select(
          "first_value(observations.id)
          OVER (PARTITION BY species_id
          ORDER BY observ_date ASC, to_timestamp(start_time, 'HH24:MI') ASC NULLS LAST)"
      ).to_a
    end

    bench.compare!
  end
end

task bench: :benchmark
