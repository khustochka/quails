class ImageFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TranslationHelper

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    @description ||= WikiFormatter.new(@model.description).for_site
  end

  def meta_description
    descr = "Снято #{l(@model.observ_date, :format => :long)}, #{@model.locus.name}."
    if description.present?
      descr << "\n"
      descr << strip_tags(description)
    end
    descr
  end

end
