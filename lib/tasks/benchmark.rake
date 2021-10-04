# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  Benchmark.ips do |bench|
    bench.report("uuid") do
      SecureRandom.uuid
    end

    bench.report("16 hex bytes") do
      SecureRandom.hex(16)
    end

    bench.compare!
  end
end

task bench: :benchmark
