class Video < Media
  include DecoratedModel

  NORMAL_PARAMS = [:slug, :title, :youtube_id, :description]

  default_scope -> { where(media_type: 'video') }

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
    "//www.youtube.com/watch?v=#{youtube_id}"
  end

  def small
    YoutubeVideo.new(youtube_id, 560, 315)
  end

  def large
    YoutubeVideo.new(youtube_id, 853, 480)
  end

  def to_thumbnail
    title = self.decorated.title + " (video)"
    Thumbnail.new(self, title, self, {video: {id: id}})
  end

  private

  def update_thumbnail
    self.assets_cache = ImageAssetsArray.new (
                                            [
                                                ImageAssetItem.new(:youtube, 480, 360, thumbnail_url_template)
                                            ]
                                        )
  end

  def thumbnail_url_template
    "//img.youtube.com/vi/#{youtube_id}/hqdefault.jpg"
  end

end
