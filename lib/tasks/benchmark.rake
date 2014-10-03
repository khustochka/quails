desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  n = 1
  Benchmark.bmbm do |bench|

    bench.report('old') { n.times {

      l = Lifelist.basic.relation
      l.count(:all)
      l.to_a
    } }

    bench.report('new') { n.times {

      l = Lifelist.simple
      l.total_count
      l.to_a

    } }

  end
end
