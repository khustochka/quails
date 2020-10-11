# frozen_string_literal: true

desc "Flickraw tasks"
namespace :flickraw do

  # Cache the current flickr methods
  task :cache => :environment do
    require 'flickr/client'

    flickr = Flickr::Client.new

    open("#{Rails.root}/lib/flickraw-cached.rb", "w") {|f|
      f.puts %{require 'flickraw'}
      f.puts %{FlickRaw::VERSION << '.#{Time.now.strftime("%Y%m%d")}-cached'}
      f.puts 'ms = %w{' + flickr.reflection.getMethods.get.to_a.join(' ') + '}'
      f.puts %{FlickRaw::Flickr.build(ms)}
    }
  end
end
