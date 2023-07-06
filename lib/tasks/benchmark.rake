# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  Benchmark.ips do |bench|
    bench.time = 5
    bench.warmup = 2

    bench.report("lateral join") do
      Lifelist::FirstSeenLateral.over(year: 2019).to_a
    end

    bench.report("partition") do
      Lifelist::FirstSeen.over(year: 2019).to_a
    end

    bench.compare!
  end
end

desc nil
task bench: :benchmark
