desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  sps = Species.scoped.to_a

  n = 100
  Benchmark.bmbm do |x|

    x.report('chunk') { n.times {
      sps.chunk { |sp| {:order => sp.order, :family => sp.family} }.each { |k, v| [k, v] }
    } }

    x.report('groupby') { n.times {
      sps.group_by { |sp| {:order => sp.order, :family => sp.family} }.each { |k, v| [k, v] }
    } }

  end
end
