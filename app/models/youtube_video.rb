# frozen_string_literal: true

class YoutubeVideo < Struct.new(:video_id, :title, :width, :height, :privacy)
  def to_partial_path
    "videos/youtube_embed"
  end

  def url
    "https://#{host}/embed/#{video_id}?enablejsapi=1&rel=0&vq=hd720"
  end

  def page_url
    "https://www.youtube.com/watch?v=#{video_id}"
  end

  private

  def host
    "www.youtube#{"-nocookie" if privacy}.com"
  end
end
