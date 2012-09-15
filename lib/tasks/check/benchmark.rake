desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    @ukr = Locus.find_by_slug('ukraine')

    n = 2000
    Benchmark.bmbm do |x|

      x.report('select all') { n.times {
        @ukr.subregion_ids0
      } }

      x.report('select values') { n.times {
        @ukr.subregion_ids1
      } }

      x.report('select flatten') { n.times {
        @ukr.subregion_ids
      } }

    end
  end
end
