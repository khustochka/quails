module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_link(sp_obj)
    sp_obj.nil? ? 'Avis incognita' : link_to(sp_obj.name, sp_obj, :class => 'sp_link')
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.nil? ? 'Avis incognita' : sp_obj.name_sci, :class => 'lat')
  end

end
