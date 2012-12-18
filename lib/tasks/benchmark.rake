desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  sps = LocalSpecies.scoped.map(&:attributes)
  @letters = ("A".."Z").cycle

  n = 1
  Benchmark.bmbm do |x|

    x.report('with search') { n.times {
      sps.each do |sp|
        item = LocalSpecies.find(sp['id'])
        item.update_attributes!(notes_ru: @letters.next)
      end
    } }

    x.report('without search') { n.times {
      sps.each do |sp|
        LocalSpecies.update(sp['id'], notes_ru: @letters.next, status: @letters.next)
      end
    } }

  end
end
