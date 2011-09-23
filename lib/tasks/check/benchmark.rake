desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'


    n = 1
    Benchmark.bmbm do |x|

      x.report('old') { n.times {

      } }

      x.report('new') { n.times {

      } }

    end
  end
end