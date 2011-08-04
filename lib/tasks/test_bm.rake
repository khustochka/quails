desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  list = Species.lifelist

  n = 500
  Benchmark.bmbm do |x|

    x.report('1st') { n.times {
      list.inject([]) do |memo, sp|
          last = memo.last
          if last.nil? || last.main_species != sp.main_species
            memo.push(sp)
          else
            memo
          end
      end
    } }

    x.report('2nd') { n.times {
      list.group_by(&:main_species).map {|k, v| v.first }
    } }
  end
end