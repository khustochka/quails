class CommentFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper

  def text
    WikiFormatter.new(
        SiteFormatStrategy.new(
            sanitize(@model.text)
        )
    ).apply
  end

end
