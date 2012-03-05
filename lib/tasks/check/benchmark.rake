desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'


    @query = {observ_date_eq: '2010-07-24'}
    @query2 = {observation_observ_date_eq: '2010-07-24'}

    n = 500
    Benchmark.bmbm do |x|

      x.report('preload+inject') { n.times {
        Observation.search(@query).result.preload(:spots).inject([]) do |memo, ob|
          memo + ob.spots
        end
      } }

      x.report('join+select') { n.times {
        Observation.search(@query).result.joins(:spots).select('lat, lng').all
      } }

      x.report('proper join') { n.times {
        Spot.joins(:observation).search(@query2).result.all
      } }

    end
  end
end