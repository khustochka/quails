class YoutubeVideo < Struct.new(:video_id, :width, :height)

  YOUTUBE_HOST = "//www.youtube.com"

  def to_partial_path
    'videos/youtube_embed'
  end

  def url
    "#{YOUTUBE_HOST}/embed/#{video_id}?enablejsapi=1&rel=0&vq=hd720"
  end

end
