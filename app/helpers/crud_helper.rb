# frozen_string_literal: true

module CrudHelper
  def new_or_edit_label(obj)
    obj.persisted? ? "Edit" : "New"
  end

  def default_submit_button(form, options = {})
    if correcting?
      # The browser submits a form on Enter using the first submit button in DOM
      # order. We want SAVE_AND_NEXT to be that default, so it is placed first in
      # the source and reordered visually via flexbox `order` to keep the layout
      # Skip / Save / Save and next.
      tag.div(style: "display: flex") do
        concat form.button(:submit, value: CorrectableConcern::SAVE_AND_NEXT_VALUE, style: "order: 3", data: { disable_with: "Saving..." })
        concat form.button(:submit, value: CorrectableConcern::SAVE_VALUE, style: "order: 2", data: { disable_with: "Saving..." })
        concat form.button(:submit, value: CorrectableConcern::SKIP_VALUE, style: "order: 1", data: { disable_with: "Skipping..." })
      end
    else
      default_value = options.delete(:value) || t(".save_button", default: "Save")
      default_options = { data: { disable_with: "Saving..." }, id: "save_button" }
      form.button :submit, *[default_value, default_options.merge!(options)].compact
    end
  end

  def default_destroy_link(rec)
    link_to rec, data: { confirm: "Object will be DESTROYED!" }, method: :delete, class: "not-green destroy" do
      tag.span(class: "fas fa-times-circle destroy-icon fa-lg", title: "Destroy", alt: "Destroy")
    end
  end

  def disabled_destroy_icon
    tag.span(class: "fas fa-times-circle disabled-icon fa-lg", title: "Destroy disabled due to existing associations", alt: "Destroy disabled")
  end

  def default_destroy_button
    button_to("DELETE", { action: :destroy }, { method: :delete, data: { confirm: "Object will be DESTROYED!" } })
  end
end
