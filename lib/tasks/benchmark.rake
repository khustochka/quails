# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  Benchmark.ips do |bench|
    bench.report("fetch with arg") do
      ENV.fetch("AIRBRAKE_PROJECT_ID", "1")
    end

    bench.report("fetch with block") do
      ENV.fetch("AIRBRAKE_PROJECT_ID") { 1 }
    end

    bench.report("or-or") do
      ENV["AIRBRAKE_PROJECT_ID"] || "1"
    end

    bench.compare!
  end
end

task bench: :benchmark
