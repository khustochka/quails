# frozen_string_literal: true

class YoutubeVideo < Struct.new(:video_id, :title, :width, :height)
  def to_partial_path
    "videos/youtube_embed"
  end

  def url
    if Rails.env.test?
      ""
    else
      "https://www.youtube-nocookie.com/embed/#{video_id}?enablejsapi=1&rel=0&vq=hd720"
    end
  end

  def direct_url
    "https://www.youtube.com/watch?v=#{video_id}"
  end
end
