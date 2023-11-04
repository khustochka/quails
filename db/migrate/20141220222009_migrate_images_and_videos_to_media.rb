class MigrateImagesAndVideosToMedia < ActiveRecord::Migration[4.2]

  class OldImage < ActiveRecord::Base
    self.table_name = 'images'
    serialize :assets_cache, coder: ImageAssetsArray
    has_and_belongs_to_many :observations, join_table: 'images_observations', foreign_key: 'image_id'
  end

  class OldVideo < ActiveRecord::Base
    self.table_name = 'videos'
    has_and_belongs_to_many :observations, join_table: 'videos_observations', foreign_key: 'video_id'
  end


  def up

    img_cache = {}

    OldImage.find_each do |im|
      attrs = im.attributes.to_hash.with_indifferent_access

      attrs.delete(:id)
      attrs[:external_id] = attrs.delete(:flickr_id)
      attrs[:media_type] = 'photo'

      m = Media.new(attrs)

      m.observations = im.observations
      m.created_at = im.created_at
      m.save

      img_cache[im.id] = m.id
    end

    Media.where('parent_id IS NOT NULL').find_each do |im|
      old = im.parent_id
      im.update_attribute(:parent_id, img_cache[old])
    end

    SpeciesImage.find_each do |sp|
      old_img = sp.image_id
      sp.update_attribute(:image_id, img_cache[old_img])
    end

    OldVideo.find_each do |vi|
      attrs = vi.attributes.to_hash.with_indifferent_access

      attrs.delete(:id)
      attrs[:external_id] = attrs.delete(:youtube_id)
      attrs[:media_type] = 'video'

      m = Media.new(attrs)

      m.observations = vi.observations
      m.created_at = vi.created_at
      m.save

    end


  end

  def down

  end

end
