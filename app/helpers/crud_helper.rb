module CrudHelper

  def new_or_edit_label(obj)
    obj.persisted? ? 'Edit' : 'New'
  end

  def default_submit_button(form, options = {})
    default_value = options.delete(:value) || t('.save_button', :default => 'Save')
    default_options = {data: {disable_with: 'Saving...'}, :id => 'save_button'}
    form.button :submit, *[default_value, default_options.merge!(options)].compact
  end

  def default_destroy_link(rec)
    link_to(
      tag(:span, class: "fa fa-times-circle destroy-icon fa-lg", title: 'Destroy', alt: 'Destroy'),
        rec, data: {confirm: 'Object will be DESTROYED!'}, method: :delete, class: 'destroy'
    )
  end

  def disabled_destroy_icon
    tag(:span, class: "fa fa-times-circle disabled-icon fa-lg", title: 'Destroy disabled due to existing associations', alt: 'Destroy disabled')
  end

  def default_destroy_button
    button_to('DELETE', {action: :destroy}, {class: "btn btn-danger", method: :delete, data: {confirm: 'Object will be DESTROYED!'}})
  end
end
