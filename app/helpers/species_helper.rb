module SpeciesHelper

  STATIC_MAP_CENTER = {
      'ukraine' => '48.6,31.2',
      'united_kingdom' => '54.8,-1.5'
  }

  NEW_SPECIES_LINK_METHOD = {
      true => :new_species_link,
      false => :species_link
  }

  def avibase_species_url(avibase_id, lang = 'EN')
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def taxa_for_select
    @taxa_for_select ||= Taxon.where(id: Observation.select("DISTINCT taxon_id")).select("id, name_sci")
  end

  def species_link(sp_obj, string = nil)
    @only_path = true if @only_path.nil?
    if sp_obj
      link_to(string || sp_obj.name, localized_species_url(id: sp_obj, only_path: @only_path), class: 'sp_link')
    else
      "Bird sp."
    end
  end

  def taxon_link(taxon)
    @only_path = true if @only_path.nil?
    link_to(taxon.name, taxon_url(id: taxon.id, only_path: @only_path), class: taxon.countable? ? "tx_link" : "spuh_link")
  end

  def new_species_link(sp_obj, string = nil)
    "<b>#{species_link(sp_obj, string)}</b><span class='new_sp' title='#{t(".new_species")}'>&#8727;</span>"
  end

  def species_link_in_flat_section(sp_obj, post_or_card, string = nil)
    method = NEW_SPECIES_LINK_METHOD[sp_obj.id.in?(post_or_card.new_species_ids)]
    self.send(method, sp_obj, string)
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, class: 'sci_name', lang: "la")
  end

  def unknown_species(text, name_sci)
    text.present? ? content_tag(:span, text, title: name_sci) : content_tag(:i, name_sci, class: 'sci_name')
  end

  def species_map(country, loci)
    center = "center=#{STATIC_MAP_CENTER[country]}"
    markers = loci.map { |l| l.lat and "#{l.lat},#{l.lon}" }.compact.join('|')
    zoom = 5
    if !country.in?(STATIC_MAP_CENTER.keys)
      lats = loci.map(&:lat).compact
      # if distance is too far rely on automatic zoom
      zoom = nil if (lats.max - lats.min).abs > 5
    end
    image_tag("http://maps.googleapis.com/maps/api/staticmap?key=#{ENV["quails_google_maps_api_key"]}&zoom=#{zoom}&size=443x300&#{center}&markers=#{markers}",
              alt: "#{country} map")
  end

  def term_highlight(string, term)
    if string && term.present?
      string.gsub(/(#{term})/i, content_tag(:span, '\1', class: "highlight")).html_safe
    else
      string
    end
  end

end
