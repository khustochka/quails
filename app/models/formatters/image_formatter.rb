class ImageFormatter < ModelFormatter

  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TranslationHelper

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    @description ||= WikiFormatter.new(@model.description).for_site
  end

  def public_locus_full_name
    @model.public_locus.formatted.full_name
  end

  def meta_description
    descr = "#{I18n.t("images.picture_taken")} #{l(@model.observ_date, :format => :long)}, #{@model.locus.name}."
    if I18n.russian_locale? && description.present?
      descr << "\n"
      descr << strip_tags(description)
    end
    descr
  end

end
