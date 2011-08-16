module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_link(sp_obj, string = nil)
    link_to(string || sp_obj.name_en, species_path(sp_obj), :class => 'sp_link')
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.is_a?(String) ? sp_obj : sp_obj.name_sci, :class => 'lat')
  end

  def extract_families(species)
    species.group_by {|sp| {:order => sp.order, :family => sp.family} }
  end

end
