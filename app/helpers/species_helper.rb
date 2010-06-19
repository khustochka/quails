module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_link(sp_obj)
    sp_obj.nil? ? 'Avis incognita' : link_to(sp_obj.name_sci, sp_obj)
  end

end
