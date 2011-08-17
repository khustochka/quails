desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'
    require 'test/unit'

    n = 10
    Benchmark.bmbm do |x|

      x.report('JOIN') { n.times {
        Observation.lifelist
      } }

      x.report('PLAIN') { n.times {
        res = Observation.find_by_sql("SELECT *
          FROM observations
          WHERE (species_id, observ_date) IN (
            SELECT species_id, MIN(observ_date)
            FROM observations
            WHERE mine = true AND species_id != 9999
            GROUP BY species_id
            )
          ORDER BY observ_date DESC").group_by(&:species_id).map { |k, v| v.first }
        Observation.send(:preload_associations, res, [:species, :post])
      } }

      x.report('OLD') { n.times {
        Species.old_lifelist
      } }

    end
  end
end