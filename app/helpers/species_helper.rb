# frozen_string_literal: true

module SpeciesHelper

  STATIC_MAP_CENTER = {
      "ukraine" => "48.6,31.2",
      "united_kingdom" => "54.8,-1.5"
  }

  NEW_SPECIES_LINK_METHOD = {
      true => :new_species_link,
      false => :species_link
  }

  def avibase_species_url(avibase_id, lang = "EN")
    "http://avibase.bsc-eoc.org/species.jsp?avibaseid=#{avibase_id}&lang=#{lang}"
  end

  def taxa_for_select
    @taxa_for_select ||= Taxon.where(id: Observation.select("DISTINCT taxon_id")).select("id, name_sci, name_en")
  end

  def species_link_long(species)
    tag.span class: "sp_link_long" do
      concat species_link(species)
      concat " "
      concat name_sci(species)
    end
  end

  # FIXME: provide alternative string as a block? Or, better, as an option key: alt_text.
  def species_link(sp_obj, string = nil, options = {})
    str = string.dup
    opts = options.dup
    # If string is not provided, and options are the second argument
    if str.is_a?(Hash)
      str = nil
      opts = string
    end
    if sp_obj
      link_to(str || sp_obj.name, localized_species_url(id: sp_obj, **opts), class: "sp_link")
    else
      "Bird sp."
    end
  end

  # FIXME: provide alternative string as a block? Or, better, as an option key: alt_text.
  def taxon_link(taxon, string = nil, options = {})
    str = string.dup
    opts = options.dup
    # If string is not provided, and options are the second argument
    if str.is_a?(Hash)
      str = nil
      opts = string
    end
    link_to(str || taxon.name, taxon_url(taxon, opts), class: taxon.countable? ? "tx_link" : "spuh_link")
  end

  def new_species_link(sp_obj, string = nil)
    "<b>#{species_link(sp_obj, string)}</b><span class='new_sp' title='#{t(".new_species")}'>&#8727;</span>"
  end

  def species_link_in_flat_section(sp_obj, post_or_card, string = nil)
    method = NEW_SPECIES_LINK_METHOD[sp_obj.id.in?(post_or_card.lifer_species_ids)]
    self.send(method, sp_obj, string)
  end

  def name_sci(sp_obj)
    content_tag(:i, sp_obj.name_sci, class: "sci_name", lang: "la")
  end

  def unknown_species(text, name_sci)
    text.present? ? content_tag(:span, text, title: name_sci) : content_tag(:i, name_sci, class: "sci_name")
  end

  def species_map(country, loci)
    center = "center=#{STATIC_MAP_CENTER[country]}"
    markers = loci.map { |l| l.lat and "#{l.lat},#{l.lon}" }.compact.join("|")
    zoom = 5
    if !country.in?(STATIC_MAP_CENTER.keys)
      lats = loci.map(&:lat).compact
      lons = loci.map(&:lon).compact
      # if distance is too far rely on automatic zoom
      zoom = nil if (lats.max - lats.min).abs > 10 || (lons.max - lons.min).abs > 12
    end
    image_tag("//maps.googleapis.com/maps/api/staticmap?key=#{ENV["quails_google_maps_api_key"]}&zoom=#{zoom}&size=421x285&#{center}&markers=#{markers}",
              alt: "#{country} map", size: "421x285")
  end

  def term_highlight(string, term)
    highlight(string, term, highlighter: content_tag(:span, '\1', class: "highlight"))
  end

end
