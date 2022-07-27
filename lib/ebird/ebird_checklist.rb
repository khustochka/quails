# frozen_string_literal: true

require "ebird/client"

class EBirdChecklist
  attr_reader :ebird_id
  attr_accessor :observ_date, :start_time, :effort_type, :duration_minutes, :distance_kms, :area_acres,
    :notes, :observers, :location_string, :observations

  PROTOCOL_TO_EFFORT = {
    "Traveling" => "TRAVEL",
    "Incidental" => "INCIDENTAL",
    "Stationary" => "STATIONARY",
    "Area" => "AREA",
    "Historical" => "HISTORICAL",
  }

  DURATION_REGEX = /^Duration: (?:(\d+) hour\(s\)(?:, )?)?(?:(\d+) minute\(s\))?$/

  def initialize(ebird_id)
    @ebird_id = ebird_id
  end

  def url
    "https://ebird.org/view/checklist/#{ebird_id}"
  end

  def edit_url
    "https://ebird.org/edit/checklist?subID=#{ebird_id}"
  end

  def fetch!(client = nil)
    agent = client || EBird::Client.new

    page = agent.fetch_checklist(self)

    parse!(page)
  end

  def fix!(client = nil)
    agent = client || EBird::Client.new

    agent.fix_checklist(self)
  end

  def to_card
    ml = notes.to_s.match?(/^ML/i)
    if /\AML\s*\Z/.match?(notes)
      self.notes = ""
    end
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
      # locus: locus,
      motorless: ml,
      observations: observations.map {|obs| Observation.new(obs)}
    )
  end

  private

  def parse!(page)
    datetime = page.at_css("div.SectionHeading-heading time")[:datetime]
    dt = Time.zone.parse(datetime)

    self.observ_date = dt.to_date
    if datetime.include?("T")
      self.start_time = dt.strftime("%R") # = %H:%M
    end

    protocol = page.at_xpath("//div[contains(@title, 'Protocol:')]/span[2]").text

    self.effort_type = PROTOCOL_TO_EFFORT[protocol]

    duration = page.at_xpath("//span[contains(@title, 'Duration:')]")&.attr(:title)
    if duration.present?
      md = duration.match(DURATION_REGEX)

      self.duration_minutes = md[1].to_i * 60 + md[2].to_i
    end

    distance = page.at_xpath("//span[contains(@title, 'Distance:')]")&.attr(:title)

    dm = distance&.match(/^Distance: ([\d.]+) (.*)$/)
    if dm
      val = dm[1].to_f
      if dm[2] == "mile(s)"
        val = val * 1.609344 # rubocop:disable Style/SelfAssignment
      end

      self.distance_kms = val
    end

    area = page.css("div.Observation-meta-item").text.match(/Area:\s+([\d.]+) ac/)
    if area
      self.area_acres = area[1]
    end
    observers = page.at_xpath("//span[contains(@title, 'Observers:')]")
    if observers
      party = observers[:title].match(/^Observers: (\d+)$/)[1]
      if party != "1"
        self.observers = party
        # self.observers = page.xpath("//dl[dt[text()='Observers:']]/dd").text. TODO: beautify the text
      end
    end

    comments = page.at_xpath("//section[h3[text()='Checklist Comments']]/p[contains(@class, 'u-constrainBody')]")&.text

    unless comments == "N/A"
      self.notes = comments
    end

    self.location_string = page.at_xpath("//div[@data-locationname]").text

    self.observations = []

    page.css("main ol li[data-observation]").each do |row|
      count = row.css("div.Observation-numberObserved span span")[1].text
      count = nil if count == "X"

      taxon = row.at_css("section")[:id]
      ebird_taxon = EBirdTaxon.find_by(ebird_code: taxon)

      tx = ebird_taxon.find_or_promote_to_taxon

      voice = false

      comments = row.at_css("div.Observation-comments")
      notes = ""
      if comments
        notes = comments.at_css("p").text&.strip
        if notes.casecmp("v").zero? || notes.downcase.start_with?("heard")
          voice = true
          notes.gsub!(/^\s*V\s*$\n*/i, "") # Remove V if it is the single letter in a line
        end
      end

      ebird_obs_id = row.at_css("a.Observation-tools-item")["data-obsid"]

      observations << { taxon: tx, quantity: count, notes: notes, voice: voice, ebird_obs_id: ebird_obs_id }
    end

    self
  end
end
