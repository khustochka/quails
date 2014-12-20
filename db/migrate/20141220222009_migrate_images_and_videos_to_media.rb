class MigrateImagesAndVideosToMedia < ActiveRecord::Migration
  def up

    img_cache = {}

    Image.find_each do |im|
      attrs = im.attributes.to_hash.with_indifferent_access

      attrs.delete(:id)
      attrs[:external_id] = attrs.delete(:flickr_id)
      attrs[:media_type] = 'photo'

      m = Media.create!(attrs)

      img_cache[im.id] = m.id

      m.observations = im.observations
      m.created_at = im.created_at
      m.save

    end

    Media.where('parent_id IS NOT NULL').find_each do |im|
      old = im.parent_id
      im.update_attribute(:parent_id, img_cache[old])
    end

    SpeciesImage.find_each do |sp|
      old_img = sp.image_id
      sp.update_attribute(:image_id, img_cache[old_img])
    end

    Video.find_each do |vi|
      attrs = vi.attributes.to_hash.with_indifferent_access

      attrs.delete(:id)
      attrs[:external_id] = attrs.delete(:youtube_id)
      attrs[:media_type] = 'video'

      m = Media.create!(attrs)

      m.observations = vi.observations
      m.created_at = vi.created_at
      m.save

    end


  end

  def down

  end

end
