desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  n = 100
  Benchmark.bm do |x|
    x.report('1st') { n.times {} }
    x.report('2nd') { n.times {} }
  end
end