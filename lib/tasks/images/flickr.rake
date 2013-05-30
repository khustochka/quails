namespace :images do

  namespace :dump do

    desc 'Dump flickr images into assets cache'
    task :flickr => :environment do

      extend FlickrApp

      Image.all.each do |img|

        slug = img.slug
        puts "Processing #{slug}"

        if img.flickr_id.present?
          img.assets_cache.swipe(:flickr)

          sizes_array = flickr.photos.getSizes(photo_id: img.flickr_id)

          sizes_array.each do |fp|
            img.assets_cache << ImageAssetItem.new(:flickr, fp["width"].to_i, fp["height"].to_i, fp["source"])
          end
          img.save!
        end

      end
    end

  end

end
