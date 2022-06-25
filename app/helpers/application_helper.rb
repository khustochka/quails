# frozen_string_literal: true

module ApplicationHelper
  def main_classes
    @main_classes ||= ["main", "green_links"]
    if @special_styling
      @main_classes.delete("green_links")
    end
    @main_classes
  end

  def page_title
    strip_tags(@page_title).try(:html_safe)&.strip || default_page_title
  end

  def page_header
    @page_header || @page_title
  end

  def default_page_title
    Rails.env.development? ? "!!! - Set the window caption / quails" : request.host
  end

  def link_to_or_span(name, options = {}, html_options = {})
    link_to_unless_current(name, options, html_options) do
      content_tag(:span, name, html_options)
    end
  end

  def filtering_link_to_all(parameter)
    if params[parameter].nil?
      content_tag(:span, t("misc.all"))
    else
      filtered = significant_params
      filtered = filtered.except(:day) if parameter.to_sym == :month
      link_to(t("misc.all"), filtered.merge(parameter => nil))
    end
  end

  def sorting_link_to(sort_value, text)
    current_sort = params[:sort].to_s == sort_value.to_s
    updated_params = significant_params.merge(sort: sort_value)
    capture do
      concat link_to_unless(current_sort, text, updated_params)
      concat "\n"
      icon = link_to_unless(current_sort, tag.span(class: %w(fas fa-sort)), updated_params, class: "force-link-color") do
        tag.span(class: %w(fas fa-caret-down))
      end
      concat icon
    end
  end

  def hide_banners?
    admin_layout? || controller_name == "maps"
  end

  def may_be_admin?
    has_trust_cookie? || current_user.admin?
  end

  def open_uri_or_path(uri)
    obj = if /\Ahttps?:\/\//.match?(uri)
            URI.parse(uri).open
          else
            File.open(uri)
          end
    yield obj
  end
end
