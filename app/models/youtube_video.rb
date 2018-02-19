class YoutubeVideo < Struct.new(:video_id, :width, :height)

  YOUTUBE_HOST = "https://www.youtube-nocookie.com"

  def to_partial_path
    'videos/youtube_embed'
  end

  def url
    "#{YOUTUBE_HOST}/embed/#{video_id}?enablejsapi=1&rel=0&vq=hd720"
  end

  def direct_url
    "#{YOUTUBE_HOST}/watch?v=#{video_id}"
  end

end
