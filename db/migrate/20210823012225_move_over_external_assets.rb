class MoveOverExternalAssets < ActiveRecord::Migration[6.1]
  def change
    Media.where.not(external_id: nil).find_each do |media|
      case media.media_type
      when "photo"
        variants = media.assets_cache.externals
        asset = media.create_external_asset!(
          service_name: "flickr",
          external_key: media.external_id,
          metadata: {width: variants.original.width, height: variants.original.height, analyzed: true}
        )
        variants.each do |variant|
          asset_variant = asset.external_asset_variants.new(
            variation_key: variant.width,
            metadata: {
              width: variant.width,
              height: variant.height,
              url: variant.url
            }
          )
          if asset_variant.invalid? && asset_variant.errors[:variation_key]
            if variant.url =~ /_o\.\w+$/
              # Add "o" to original if width is not unique and it is original
              asset_variant.variation_key = "%so" % variant.width
              asset_variant.save!
            else
              # If it is not the original - just ignore
            end
          else
            asset_variant.save!
          end
        end
      when "video"
        variants = [
          ["maxresdefault", 1280, 720],
          ["sddefault", 640, 480],
          ["hqdefault", 480, 360]
        ]
        asset = media.create_external_asset!(
          service_name: "youtube",
          external_key: media.external_id,
          metadata: {width: 1280, height: 720, analyzed: true}
        )
        variants.each do |variant|
          key, width, height = variant
          asset.external_asset_variants.create!(
            variation_key: key,
            metadata: {
              width: width,
              height: height,
              url: "https://img.youtube.com/vi/#{media.external_id}/#{key}.jpg"
            }
          )
        end
      else
        nil
      end
    end
  end
end
