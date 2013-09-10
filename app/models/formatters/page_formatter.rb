class PageFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TranslationHelper

  def title
    OneLineFormatter.apply(@model.title)
  end

  def text
    @description ||= WikiFormatter.new(@model.text).for_site
  end

end
