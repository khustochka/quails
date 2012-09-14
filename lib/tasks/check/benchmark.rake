desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    @ukr = Locus.find_by_slug('ukraine')

    n = 500
    Benchmark.bmbm do |x|

      x.report('Instantiating') { n.times {
        @ukr.get_subregions
      } }

      x.report('Ruby recursive') { n.times {
        @ukr.subregion_ids0
      } }

      x.report('PGSQL recursive') { n.times {
        @ukr.subregion_ids
      } }

    end
  end
end
