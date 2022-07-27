# frozen_string_literal: true

desc "Quick benchmark"
task benchmark: :environment do
  require "benchmark/ips"

  Benchmark.ips do |bench|
    bench.report("real then test plaintext") do
      Quails::CredentialsCheck.__send__(:match_password, "admin")
    end

    bench.report("test then real plaintext") do
      Quails::CredentialsCheck.__send__(:match_password1, "admin")
    end

    bench.report("real then test incorrect") do
      Quails::CredentialsCheck.__send__(:match_password, "abcde")
    end

    bench.report("test then real incorrect") do
      Quails::CredentialsCheck.__send__(:match_password1, "abcde")
    end

    bench.compare!
  end
end

desc nil
task bench: :benchmark
