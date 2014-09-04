class YoutubeVideo < Struct.new(:video_id, :width, :height)
  def to_partial_path
    'videos/youtube_embed'
  end
  def url
    "//www.youtube.com/embed/#{video_id}/?vq=hd720"
  end
end
