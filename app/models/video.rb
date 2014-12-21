class Video < Media
  include FormattedModel

  NORMAL_PARAMS = [:slug, :title, :youtube_id, :description]

  default_scope -> { where(media_type: 'video') }

  validates :external_id, presence: true

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

end
