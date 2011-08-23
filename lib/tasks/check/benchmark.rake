desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    n = 10
    Benchmark.bmbm do |x|

      x.report('DB') { n.times {
        require 'legacy/models/blog'
        require 'legacy/models/geography'
        require 'legacy/models/observation'
        require 'legacy/models/image'
        Legacy::Utils.db_connect

        countries = Legacy::Models::Country.all
        regions = Legacy::Models::Region.all
        locs = Legacy::Models::Location.all
        posts = Legacy::Models::Post.all
        observations = Legacy::Models::Observation.all
        images = Legacy::Models::Image.all
      } }

      x.report('FILE') { n.times {
        f = File.open('/home/vkhust/bwdata/legacy/db_dump.yml', encoding: 'windows-1251:utf-8')
        dump = YAML.load(f.read)
        countries = Legacy::Utils.prepare_table(dump['country'])
        regions = Legacy::Utils.prepare_table(dump['region'])
        locs = Legacy::Utils.prepare_table(dump['location'])
        posts = Legacy::Utils.prepare_table(dump['blog'])
        observations = Legacy::Utils.prepare_table(dump['observation'])
        images = Legacy::Utils.prepare_table(dump['images'])
      } }

    end
  end
end