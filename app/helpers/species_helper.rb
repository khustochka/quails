module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_link(sp_obj)
    link_to(sp_obj.name, sp_obj, :class => 'sp_link')
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, :class => 'lat')
  end

  def extract_families(species)
    species.inject([]) do |memo, sp|
      last = memo.last
      if last.nil? || last[:name] != sp.family
        memo.push({:name => sp.family, :order => sp.order, :species => [sp]})
      else
        last[:species].push(sp)
      end
      memo
    end
  end

end
