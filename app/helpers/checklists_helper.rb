module ChecklistsHelper

  def convert_statuses(st_string)
    str = st_string.split.map do |st|
      translate(st, scope: 'checklists.show.status')
    end.join(', ')
    RedCloth.new(str, [:no_span_caps, :lite_mode]).to_html.html_safe
  end

end
