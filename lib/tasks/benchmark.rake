desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  img = Image.where(slug: "woodpecker22969").first
  sp = img.species.first

  n = 3000
  Benchmark.bmbm do |x|

    x.report('old') { n.times {
      img.prev_by_species(sp)
    } }

    x.report('newest') { n.times {
      img.prev_by_species3(sp)
    } }

    x.report('new') { n.times {
      img.prev_by_species2(sp)
    } }

  end
end
