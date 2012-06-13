module CrudHelper

  def new_or_edit_label(obj)
    obj.persisted? ? 'Edit' : 'New'
  end

  def default_submit_button(form)
    form.button :submit, :value => t('.save_button', :default => 'Save'), 'data-disable-with' => "Saving...", :id => 'save_button'
  end

  def default_destroy_link(rec)
    link_to image_tag('/img/x_alt_16x16.png', title: 'Destroy'), rec, data: {confirm: 'Are you sure?'}, method: :delete, class: 'destroy'
  end
end
