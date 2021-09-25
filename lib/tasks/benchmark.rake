# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  Benchmark.ips do |bench|
    bench.report("=~ positive") do
      "Abcdefghijk" =~ /jk$/
    end

    bench.report("=~ negative") do
      "Abcdefghijk" =~ /cz$/
    end

    bench.report("match? positive") do
      "Abcdefghijk".match?(/jk$/)
    end

    bench.report("match? negative") do
      "Abcdefghijk".match?(/cz$/)
    end

    bench.report("regex match? positive") do
      /jk$/.match?("Abcdefghijk")
    end

    bench.report("regex match? negative") do
      /cz$/.match?("Abcdefghijk")
    end

    bench.compare!
  end
end

task bench: :benchmark
