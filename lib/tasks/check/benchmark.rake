desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    @ukr = Locus.find_by_slug('ukraine')

    n = 500
    Benchmark.bmbm do |x|

      x.report('join') { n.times {
        Species.select("DISTINCT species.id").joins(:observations).merge(MyObservation.scoped).count
      } }

      x.report('subquery') { n.times {
        Species.where("id IN (#{MyObservation.select(:species_id).to_sql})").count
      } }

    end
  end
end
