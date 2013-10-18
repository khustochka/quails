module SpeciesHelper

  STATIC_MAP_CENTER = {
      'ukraine' => '48.6,31.2',
      'usa' => '42.5,-74'
  }

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def species_for_select
    @species_for_select ||= [Species::AVIS_INCOGNITA] + Species.by_abundance.to_a
  end

  def species_link(sp_obj, string = nil)
    @only_path = true if @only_path.nil?
    link_to(string || sp_obj.name, species_path(sp_obj, only_path: @only_path), class: 'sp_link')
  end

  def new_species_link(sp_obj, string = nil)
    "<b>#{species_link(sp_obj, string)}</b><span class='new_sp' title='#{t(".new_species")}'>&#8727;</span>"
  end

  def species_link_in_post(sp_obj, post, string = nil)
    sp_obj.id.in?(post.new_species_ids) ? new_species_link(sp_obj, string) : species_link(sp_obj, string)
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, class: 'sci_name', lang: "la")
  end

  def unknown_species(text, name_sci)
    text.present? ? content_tag(:span, text, title: name_sci) : content_tag(:i, name_sci, class: 'sci_name')
  end

  def species_map(country, loci)
    center = "center=#{STATIC_MAP_CENTER[country]}"
    markers = loci.map {|l| "#{l.lat},#{l.lon}"}.join('|')
    image_tag("http://maps.googleapis.com/maps/api/staticmap?zoom=5&size=443x300&sensor=false&#{center}&markers=#{markers}")
  end

end
