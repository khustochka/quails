class CommentFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper

  def text
    WikiFormatter.new(sanitize(@model.text)).for_site
  end

end
