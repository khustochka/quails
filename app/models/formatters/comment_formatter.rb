class CommentFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper

  def text
    sanitize(
        WikiFormatter.new(@model.text).for_site
    )
  end

end
