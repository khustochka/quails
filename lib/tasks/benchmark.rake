desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  @rel = MyObservation.aggregate_by_species(:min).
      having("EXTRACT(year FROM MIN(observ_date)) = 2012")

  n = 1000
  Benchmark.bmbm do |x|

    x.report('size') { n.times {
      @rel.reload.all.size
    } }

    x.report('subquery') { n.times {
      Observation.from("(#{@rel.to_sql}) AS obs").count
    } }

  end
end
