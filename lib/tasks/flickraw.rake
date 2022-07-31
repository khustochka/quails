# frozen_string_literal: true

desc "Flickraw tasks"
namespace :flickraw do
  # Cache the current flickr methods
  task cache: :environment do
    api_methods = FlickRaw::Flickr.new.call('flickr.reflection.getMethods')

    open("#{Rails.root}/lib/flickraw-cached.rb", "w") do |f|
      f.puts <<~RUBY
        require "flickraw"

        if Flickr.flickr_objects.empty?
          FlickRaw::VERSION << ".#{Time.now.strftime("%Y%m%d")}-cached"
          api_methods = %w{#{api_methods.to_a.join(" ")}}
          FlickRaw::Flickr.build(api_methods)
        end
      RUBY
    end
  end
end
