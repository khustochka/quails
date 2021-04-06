# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  def func
    false
  end

  Benchmark.ips do |bench|
    bench.report("cache read") do
      "views/layouts/application:4ff8ef6c2bed23a819e4feaffde9b18e/shynet/show_shynet=#{func}"
    end

    bench.report("if") do
      if func
        puts "This never happens"
      end
    end

    bench.compare!
  end
end

task bench: :benchmark
