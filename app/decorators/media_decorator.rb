# frozen_string_literal: true

class MediaDecorator < ModelDecorator
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TranslationHelper

  def title
    OneLineFormatter.apply(@model.public_title)
  end

  def description
    @description ||= WikiFormatter.new(@model.description).for_site
  end

  def public_locus_full_name
    @model.public_locus.decorated.full_name
  end

  def meta_description
    descr = "#{I18n.t("#{@model.class.to_s.tableize}.taken_clause", title: title)} #{l(@model.observ_date, format: :long)}, #{public_locus_full_name}."
    # FIXME: refactor, use view context
    if I18n.locale == :ru && description.present?
      descr << "\n"
      descr << strip_tags(description)
    end
    descr
  end
end
