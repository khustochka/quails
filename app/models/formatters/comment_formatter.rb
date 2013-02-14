class CommentFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper

  def text
    WikiFormatter.new(SiteFormatStrategy.new).apply(sanitize(@model.text))
  end

end
