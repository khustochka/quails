namespace :images do

  namespace :dump do

    desc 'Dump flickr images into assets cache'
    task :flickr => :environment do

      extend FlickrApp

      Image.all.each do |img|

        slug = img.slug
        puts "Processing #{slug}"

        if img.flickr_id.present?
          img.set_flickr_data(flickr)
          img.save!
        end

      end
    end

  end

end
