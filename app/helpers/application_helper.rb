module ApplicationHelper

  def page_title
    strip_tags(@page_title) || default_page_title
  end

  def default_page_title
    Rails.env.development? ? '!!! - Set the window caption / quails3' : request.host
  end

  def link_to_or_span(name, options = {}, html_options = {})
    link_to_unless_current(name, options, html_options) do
      content_tag(:span, name, html_options)
    end
  end
  
  def default_submit_button(form)
    form.button :submit, :value => 'Save', 'data-disable-with' => "Saving..."
  end
  
  def default_destroy_link(rec)
    link_to image_tag('x_alt_16x16.png', :title => 'Destroy'), rec, :confirm => 'Are you sure?', :method => :delete, :class => 'destroy'
  end

end
