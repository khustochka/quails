# frozen_string_literal: true

module Medias
  class PhotoRepresentation
    attr_reader :media

    FULL_SIZE_WIDTH = 2400
    WEBPAGE_THUMB_WIDTH = 1200

    def initialize(media)
      @media = media
    end

    def full_size
      @full_size ||= PhotoEmbed.new(media, desired_width: FULL_SIZE_WIDTH)
    end

    def webpage_thumb
      @webpage_thumb ||= PhotoEmbed.new(media, desired_width: WEBPAGE_THUMB_WIDTH)
    end
  end
end
