desc 'Service tasks'
namespace :check do

  desc 'Quick benchmark'
  task :benchmark => :environment do
    require 'benchmark'

    include ActionView::Helpers::UrlHelper

    page_title = 'Species seen after more than a year'
    research_path = "/reaserch"

    n = 100000
    Benchmark.bmbm do |x|

      x.report('template') { n.times {
        '%s : %s' % [link_to('Research', research_path), page_title]
      } }

      x.report('concat') { n.times {
        link_to('Research', research_path) + ' : ' + page_title
      } }

      x.report('extrapol') { n.times {
        "#{link_to('Research', research_path)} : #{page_title}"
      } }

      x.report('join') { n.times {
        [link_to('Research', research_path), page_title].join(' : ')
      } }

    end
  end
end