# frozen_string_literal: true

require "ebird/client"

module EBird
  class Alert
    Location = Data.define(:name, :lat, :lng)
    Observation = Data.define(:species_name, :species_sci, :species_code, :count, :date, :checklist_id, :observer)

    # Parses "Name,SID;Name2,SID2" from EBIRD_ALERTS env var.
    def self.configured
      raw = ENV["EBIRD_ALERTS"].presence
      return [] unless raw

      raw.split(";").filter_map do |entry|
        name, sid = entry.strip.split(",", 2).map(&:strip)
        { name: name, sid: sid } if name.present? && sid.present?
      end
    end

    def self.fetch(sid)
      client = EBird::Client.new
      client.authenticate
      agent = client.instance_variable_get(:@agent)
      page = agent.get("https://ebird.org/alert/summary?sid=#{sid}")
      parse(page)
    end

    def self.parse(page)
      obs_nodes = page.css("div.Observation")
      by_location = {}

      obs_nodes.each do |node|
        species_link = node.css(".Observation-species a").first
        next unless species_link

        species_name = species_link.css(".Heading-main").text.strip
        species_sci  = species_link.css(".Heading-sub").text.strip
        species_code = species_link["data-species-code"]

        count_text = node.css(".Observation-numberObserved span").last&.text&.strip
        count = count_text.to_i if count_text

        checklist_link = node.css(".Observation-meta a[href*='/checklist/']").first
        date = checklist_link&.text&.strip
        checklist_id = checklist_link&.[]("href")&.sub("/checklist/", "")

        observer = node.css(".Observation-meta .GridFlex-cell:last-child .GridFlex-cell.u-sizeFill span:last-child").text.strip

        location_link = node.css("a[href*='google.com/maps']").first
        next unless location_link

        loc_name = location_link.text.strip
        maps_url = location_link["href"]
        coords = maps_url.match(/query=([-\d.]+),([-\d.]+)/)
        next unless coords

        lat = coords[1].to_f
        lng = coords[2].to_f
        loc_key = "#{lat},#{lng}"

        by_location[loc_key] ||= { location: Location.new(name: loc_name, lat: lat, lng: lng), observations: [] }
        by_location[loc_key][:observations] << Observation.new(
          species_name: species_name,
          species_sci: species_sci,
          species_code: species_code,
          count: count,
          date: date,
          checklist_id: checklist_id,
          observer: observer
        )
      end

      by_location.values
    end
  end
end
