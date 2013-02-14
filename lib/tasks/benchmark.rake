desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  Lifelist.class_eval do

    def lifers_aggregation2
      @observation_source.filter(@filter).
          select("distinct on(species_id) id, species_id, observ_date, post_id").
          order('species_id, observ_date ASC')
    end

  end

  n = 100
  Benchmark.bmbm do |x|

    x.report('old lifelist') { n.times {
      Lifelist.basic.send(:lifers_aggregation).to_a
    } }

    x.report('new lifelist') { n.times {
      Lifelist.basic.send(:lifers_aggregation2).to_a
    } }

  end
end
