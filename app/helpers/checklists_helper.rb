module ChecklistsHelper

  def convert_status(str)
    RedCloth.new(str, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

end
