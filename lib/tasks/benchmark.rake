desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  n = 1000
  Benchmark.bmbm do |x|

    x.report('old') { n.times {

      @img = Image.find_by_slug('sparrow4603')
      @sp = @img.species.first

      @img.prev_by_species0(@sp)
      @img.next_by_species0(@sp)

    } }

    x.report('window') { n.times {

      @img = Image.find_by_slug('sparrow4603')
      @sp = @img.species.first

      @img.prev_by_species(@sp)
      @img.next_by_species(@sp)

    } }

  end
end
