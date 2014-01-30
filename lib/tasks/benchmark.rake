desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  module SimpleCache
    def self.quails_google_cse
      @quails_google_cse ||= ENV['quails_google_cse']
    end
  end

  n = 10000000
  Benchmark.bmbm do |bench|

    bench.report('env') { n.times {

      z = ENV['quails_google_cse']

    } }

    bench.report('module cache') { n.times {

      y = SimpleCache.quails_google_cse

    } }

  end
end
