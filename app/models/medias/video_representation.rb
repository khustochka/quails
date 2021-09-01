# frozen_string_literal: true

module Medias
  class VideoRepresentation
    attr_reader :media

    def initialize(media, privacy: true)
      @media = media
      @privacy = privacy
    end

    # Flow_thumbnail?
    def small
      YoutubeVideo.new(youtube_id, media.decorated.title, 560, 315, @privacy)
    end

    # Column size figure?
    def medium
      YoutubeVideo.new(youtube_id, media.decorated.title, 640, 360, @privacy)
    end

    def full_size
      YoutubeVideo.new(youtube_id, media.decorated.title, 896, 504, @privacy)
    end

    private
    def youtube_id
      media.external_asset.external_key
    end
  end
end
