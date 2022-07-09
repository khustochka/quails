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

    bench.report("urlsafe") do
      SecureRandom.urlsafe_base64(20 * 3 / 4)
    end

    bench.compare!
  end
end

desc nil
task bench: :benchmark
