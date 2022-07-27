# frozen_string_literal: true

namespace :images do
  namespace :dump do
    desc "Dump flickr images into assets cache"
    task flickr: :environment do
      Image.where.not(external_id: nil).each do |img|
        slug = img.slug
        puts "Processing #{slug}"

        FlickrPhoto.new(img).refresh!
      end
    end
  end
end
