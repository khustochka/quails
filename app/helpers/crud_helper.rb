# frozen_string_literal: true

module CrudHelper
  def new_or_edit_label(obj)
    obj.persisted? ? "Edit" : "New"
  end

  def default_submit_button(form, options = {})
    if correcting?
      capture do
        concat form.button(:submit, value: CorrectableConcern::SKIP_VALUE, data: { disable_with: "Skipping..." })
        concat form.button(:submit, value: CorrectableConcern::SAVE_VALUE, data: { disable_with: "Saving..." })
        concat form.button(:submit, value: CorrectableConcern::SAVE_AND_NEXT_VALUE, data: { disable_with: "Saving..." })
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
