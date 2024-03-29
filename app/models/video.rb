# frozen_string_literal: true

class Video < Media
  include DecoratedModel

  invalidates Quails::CacheKey.gallery

  NORMAL_PARAMS = [:slug, :title, :youtube_id, :description]

  default_scope -> { where(media_type: "video") }

  validates :external_id, presence: true

  before_save do
    if new_record? || changed_attributes.has_key?(:external_id)
      update_thumbnail
    end
  end

  # Update

  def youtube_id
    external_id
  end

  def youtube_id=(val)
    self.external_id = val
  end

  def youtube_url
    "https://www.youtube.com/watch?v=#{youtube_id}"
  end

  def small
    YoutubeVideo.new(youtube_id, decorated.title, 560, 315)
  end

  def medium
    YoutubeVideo.new(youtube_id, decorated.title, 640, 360)
  end

  def large
    YoutubeVideo.new(youtube_id, decorated.title, 853, 480)
  end

  def to_thumbnail
    Thumbnail.new(self, decorated.title, self, { video: { id: id } })
  end

  def on_storage?
    false
  end

  private

  def update_thumbnail
    self.assets_cache = ImageAssetsArray.new(
      [
        ImageAssetItem.new(:youtube, 480, 360, thumbnail_url_template),
      ]
    )
  end

  def thumbnail_url_template
    "https://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg"
  end
end
