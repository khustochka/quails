desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  sps = LocalSpecies.scoped.map(&:attributes)

  n = 10
  Benchmark.bmbm do |x|

    x.report('with search') { n.times {
      sps.each do |sp|
        item = LocalSpecies.find(sp['id'])
        item.update_attributes!(notes_ru: sp['notes_ru'])
      end
    } }

    x.report('shorter') { n.times {
      sps.each do |sp|
        LocalSpecies.update(sp['id'], notes_ru: sp['notes_ru'])
      end
    } }

    x.report('without search') { n.times {
      sps.each do |sp|
        LocalSpecies.where(id: sp['id']).update_all(notes_ru: sp['notes_ru'])
      end
    } }

    x.report('in transaction') { n.times {
      LocalSpecies.transaction do
        sps.each do |sp|
          LocalSpecies.where(id: sp['id']).update_all(notes_ru: sp['notes_ru'])
        end
      end
    } }

  end
end
