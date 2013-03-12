module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_for_select
    @species_for_select ||= [Species::AVIS_INCOGNITA] + Species.alphabetic.to_a
  end

  def species_link(sp_obj, string = nil)
    link_to(string || sp_obj.name, species_path(sp_obj), class: 'sp_link')
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, class: 'sci_name')
  end

  def unknown_species(text, name_sci)
    text.present? ? content_tag(:span, text, title: name_sci) : content_tag(:i, name_sci, class: 'sci_name')
  end

end
