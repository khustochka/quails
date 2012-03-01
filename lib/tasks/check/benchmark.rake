desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'


    @query = {observ_date_eq: '2010-07-24'}

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

    end
  end
end