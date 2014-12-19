desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark/ips'

  SomeData = Struct.new(:a, :b, :c)

  Benchmark.ips do |bench|

    bench.report('struct') do

      x = SomeData.new(1, "a", 2)
      x.a
      x.b
      x.c

    end

    bench.report('open-struct') do

      x = OpenStruct.new(a: 1, b: "a", c: 2)
      x.a
      x.b
      x.c

    end

    bench.report('hashie::mash') do

      x = Hashie::Mash.new(a: 1, b: "a", c: 2)
      x.a
      x.b
      x.c

    end

    bench.report('hash') do

      x = {a: 1, b: "a", c: 2}
      x[:a]
      x[:b]
      x[:c]

    end

    bench.compare!

  end
end

task :bench => :benchmark
