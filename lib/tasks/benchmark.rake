desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  img = Image.where(slug: "woodpecker22969").first

  n = 100000
  Benchmark.bmbm do |x|

    x.report('inject') { n.times {
      img.assets_cache.main_image
    } }

    x.report('sort') { n.times {
      img.assets_cache.externals.sort_by {|a| a.width}.find {|a| a.width >= 894}
    } }

  end
end
