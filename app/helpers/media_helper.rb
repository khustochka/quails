# frozen_string_literal: true

module MediaHelper
  def media_for_main_page(media)
    render "#{media.media_type.pluralize}/main_page_presentation", media: media
  end
end
