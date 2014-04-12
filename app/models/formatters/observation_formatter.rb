class ObservationFormatter < ModelFormatter

  def species_str
    str = [["<b>#{@model.species.name}</b>", @model.species.name_sci].join(' '), @model.quantity, @model.notes].
        delete_if(&:'blank?').join(', ')
    str += " <small class='voice tag'>voice</small>" if @model.voice
    str.html_safe
  end

  def when_where_str
    [@model.card.observ_date, "<b>#{@model.patch_or_locus.name_en}</b>", @model.place].delete_if(&:'blank?').join(', ').html_safe
  end

end
