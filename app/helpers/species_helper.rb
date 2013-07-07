module SpeciesHelper

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_for_select
    @species_for_select ||= [Species::AVIS_INCOGNITA] + Species.by_abundance.all
  end

  def species_link(sp_obj, string = nil)
    link_to(string || sp_obj.name, species_path(sp_obj), class: 'sp_link')
  end

  def new_species_link(sp_obj)
    "<b>#{species_link(sp_obj)}</b><span class='new_sp' title='#{t("posts.show.new_species")}'>&#8727;</span>"
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, class: 'sci_name', lang: "la")
  end

  def unknown_species(text, name_sci)
    text.present? ? content_tag(:span, text, title: name_sci) : content_tag(:i, name_sci, class: 'sci_name')
  end

end
