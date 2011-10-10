desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'


    @search = Observation.search(nil)
	
    n = 500
    Benchmark.bmbm do |x|

      x.report('includes') { n.times {
		@search.result.order('species.index_num').includes(:locus, :post, :species).page(10).all
      } }

      x.report('preload') { n.times {
		@search.result.order('species.index_num').preload(:locus, :post).includes(:species).page(10).all
      } }

    end
  end
end