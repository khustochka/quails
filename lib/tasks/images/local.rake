# frozen_string_literal: true

namespace :images do
  namespace :dump do
    desc "Dump local images into assets cache"
    task local: :environment do
      local_dir = ENV["LOCAL_DIR"]
      raise "Set LOCAL_DIR" unless local_dir

      Image.all.each do |img|
        slug = img.slug
        puts "Processing #{slug}"

        img.assets_cache.swipe(:local)

        [slug, "tn_#{slug}"].each do |fn|
          fname = "#{fn}.jpg"

          if File.exist?("#{local_dir}/#{fname}")
            w, h = `identify -format "%Wx%H" #{local_dir}/#{fname}`.split("x").map(&:to_i)

            img.assets_cache << ImageAssetItem.new(:local, w, h, fname)
          end
        end
        img.save!
      end
    end
  end
end
