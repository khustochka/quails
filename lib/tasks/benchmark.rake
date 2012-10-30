desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

@cnt = ResearchController.new

  n = 30
  Benchmark.bmbm do |x|

    x.report('more_than_year_no_inst') { n.times {
      @cnt.send(:more_than_year_no_inst)
    } }

    x.report('more_than_year_no_inst_flat') { n.times {
      @cnt.send(:more_than_year_no_inst_flat)
    } }

    x.report('more_than_year_no_inst2') { n.times {
      @cnt.send(:more_than_year_no_inst)
    } }

    x.report('more_than_year_no_inst_flat2') { n.times {
      @cnt.send(:more_than_year_no_inst_flat)
    } }

  end
end
