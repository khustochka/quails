desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    @query = {observ_date_eq: '2010-07-24'}
    @query2 = {observation_observ_date_eq: '2010-07-24'}

    n = 500
    Benchmark.bmbm do |x|

      x.report('manual join') { n.times {
        Spot.
            joins("JOIN (#{Observation.search(@query).result.to_sql}) as obs ON observation_id=obs.id").
            select('lat, lng')
      } }

      x.report('join+merge') { n.times {
        Spot.
            joins(:observation).merge(Observation.search(@query).result).
        select('lat, lng')
      } }

    end
  end
end