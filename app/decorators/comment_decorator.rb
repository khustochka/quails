# frozen_string_literal: true

class CommentDecorator < ModelDecorator

  include ActionView::Helpers::SanitizeHelper

  ALLOWED_TAGS = %w(strong em b i p pre tt sub
      sup cite br ul ol li dl dt dd abbr
      acronym a img blockquote del ins)

  ALLOWED_ATTRIBUTES = %w(href src width height alt cite datetime title name abbr)

  def text
    sanitize(
        WikiFormatter.new(@model.text).for_site,
        tags: ALLOWED_TAGS,
        attributes: ALLOWED_ATTRIBUTES
    )
  end

  def name
    strip_tags(@model.name)
  end

end
