# frozen_string_literal: true

module MediaHelper
  def full_size_media(media)
    render "#{media.media_type.pluralize}/presentations/full_size", media: media
  end
end
