module ObservationsHelper
  
  def obs_species_span(ob)
    [[species_link(ob.species), name_sci(ob.species)].join(' '), ob.quantity, ob.notes].
        delete_if(&:'blank?').join(', ').html_safe
  end
  
  def obs_when_where_span(ob)
    [ob.observ_date, ob.locus.name_en, ob.place].delete_if(&:'blank?').join(', ')
  end
  
end
