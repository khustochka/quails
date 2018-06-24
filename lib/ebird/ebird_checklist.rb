require "ebird/ebird_client"

class EbirdChecklist

  attr_reader :ebird_id
  attr_accessor :observ_date, :start_time, :effort_type, :duration_minutes, :distance_kms, :area_acres,
                :notes, :observers, :location_string, :observations

  PROTOCOL_TO_EFFORT = {
      "Traveling" => "TRAVEL",
      "Incidental" => "INCIDENTAL",
      "Stationary" => "STATIONARY",
      "Area" => "AREA",
      "Historical" => "HISTORICAL"
  }


  def initialize(ebird_id)
    @ebird_id = ebird_id
  end

  def url
    "https://ebird.org/view/checklist/#{ebird_id}"
  end

  def fetch!(client = nil)
    agent = client || EbirdClient.new

    page = agent.fetch_checklist(self)

    parse!(page)

  end

  def to_card

    Card.new(
            ebird_id: ebird_id,
            observ_date: observ_date,
            start_time: start_time,
            effort_type: effort_type,
            duration_minutes: duration_minutes,
            distance_kms: distance_kms,
            area_acres: area_acres,
            observers: observers,
            notes: notes || "",
            #locus: locus,
            observations: observations.map {|obs| Observation.new(obs)}
    )

  end

  private

  def parse!(page)
    datetime = page.css("h5.rep-obs-date").text
    dt = Time.zone.parse(datetime)

    self.observ_date = dt.to_date
    if datetime =~ /\d:\d\d( (AM|PM))?[\s]*$/
      self.start_time = dt.strftime("%R") # = %H:%M
    end

    protocol = page.xpath("//dl[dt[text()='Protocol:']]/dd").text

    self.effort_type = PROTOCOL_TO_EFFORT[protocol]

    duration = page.xpath("//dl[dt[text()='Duration:']]/dd").text
    if duration.present?
      md = duration.match(/^(?:(\d+) hour\(s\), )?(\d+) minute\(s\)$/)

      self.duration_minutes = md[1].to_i * 60 + md[2].to_i
    end

    distance = page.xpath("//dl[dt[text()='Distance:']]/dd").text

    dm = distance.match(/^([\d.]+) (.*)$/)
    if dm
      val = dm[1].to_f
      if dm[2] == "mile(s)"
        val = val * 1.609344
      end

      self.distance_kms = val
    end

    area = page.css("div.bd").text.match(/Area:\s+([\d.]+) ac/)
    if area
      self.area_acres = area[1]
    end

    party = page.xpath("//dl[dt[text()='Party Size:']]/dd").text
    if party != "1"
      self.observers = party
      #self.observers = page.xpath("//dl[dt[text()='Observers:']]/dd").text. TODO: beautify the text
    end

    comments = page.css("dl.report-comments dd").text

    unless comments == "N/A"
      self.notes = comments
    end

    self.location_string = page.css("h5.obs-loc").text

    self.observations = []

    page.css(".spp-entry").each do |row|
      count = row.css(".se-count").text
      count = nil if count == "X"

      taxon = row.css("h5.se-name").children[0].text.strip
      tx = EbirdTaxon.find_by_name_en(taxon).taxon

      voice = false

      notes = row.css(".obs-comments").text
      if notes.downcase == "v" || notes.downcase.start_with?("heard")
        notes = ""
        voice = true
      end

      self.observations << {taxon: tx, quantity: count, notes: notes, voice: voice}

    end

    self
  end

end
