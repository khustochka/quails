class ObservationFormatter < ModelFormatter

  def species_str
    str = [["<b>#{@model.taxon.name}</b>", @model.taxon.name_sci].join(' '), @model.quantity, @model.notes].
        delete_if(&:'blank?').join(', ')
    str += " <small class='voice tag'>voice</small>" if @model.voice
    str.html_safe
  end

  def when_where_str
    date_time = [
        @model.card.observ_date,
        @model.card.start_time ? "(#{@model.card.start_time})" : nil
    ].compact.join(" ")
    [date_time, "<b>#{@model.patch_or_locus.name_en}</b>", @model.private_notes].delete_if(&:'blank?').join(', ').html_safe
  end

end
