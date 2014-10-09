desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  SomeData = Struct.new(:a, :b, :c)

  n = 100000
  Benchmark.bmbm do |bench|

    bench.report('struct') { n.times {

      x = SomeData.new(1, "a", 2)
      x.a
      x.b
      x.c

    } }

    bench.report('hashie::mash') { n.times {

      x = Hashie::Mash.new(a: 1, b: "a", c: 2)
      x.a
      x.b
      x.c

    } }

  end
end
