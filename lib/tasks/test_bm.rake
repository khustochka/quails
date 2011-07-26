desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  list = Locus.list_order.group_by(&:loc_type)

  n = 1000
  Benchmark.bmbm do |x|

    x.report('1st') { n.times {
      Locus::TYPES.reverse.map { |type| list[type] }.compact.flatten
    } }

    x.report('2nd') { n.times {
      Locus::TYPES.reverse.inject([]) {|memo, type| memo.concat(list[type] || []) }
    } }
  end
end