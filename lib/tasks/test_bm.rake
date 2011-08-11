desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  n = 10
  Benchmark.bmbm do |x|

    x.report('1st') { n.times {
      Species.old_lifelist
    } }

    x.report('2nd') { n.times {
      Observation.lifelist.all
    } }
  end
end