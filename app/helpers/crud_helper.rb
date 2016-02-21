module CrudHelper

  def new_or_edit_label(obj)
    obj.persisted? ? 'Edit' : 'New'
  end

  def default_submit_button(form, options = {})
    default_option = {:value => t('.save_button', :default => 'Save'), data: {disable_with: 'Saving...'}, :id => 'save_button', class: "btn btn-primary"}
    form.button :submit, default_option.merge!(options)
  end

  def default_destroy_link(rec)
    link_to "", rec, title: 'Destroy', data: {confirm: 'Object will be DESTROYED!'}, method: :delete, class: 'destroy oi oi-circle-x icon-danger'
  end

  def disabled_destroy_icon
    content_tag(:span, "", class: "oi oi-circle-x text-muted", title: 'Destroy disabled due to existing associations')
  end

  def default_destroy_button
    button_to('DELETE', {action: :destroy}, {method: :delete, data: {confirm: 'Object will be DESTROYED!'}, class: "btn btn-danger"})
  end
end
