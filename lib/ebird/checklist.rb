# frozen_string_literal: true

require "ebird/client"

module EBird
  class Checklist
    attr_reader :ebird_id
    attr_accessor :observ_date, :start_time, :protocol, :duration_minutes, :distance_kms, :area_acres,
      :notes, :observers, :location_string, :observations, :complete

    DURATION_REGEX = /^Duration:\s*(?:(\d+) hour\(s\)(?:, )?)?(?:(\d+) minute\(s\))?$/

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
      ExternalChecklist::CardBuilder.new(ebird_id, to_h).card
    end

    def to_h
      { observ_date:, start_time:, protocol:, duration_minutes:, distance_kms:, area_acres:,
        observers:, notes:, complete:, observations:, }
    end

    private

    def parse!(page)
      datetime = page.at_css("div.SectionHeading-heading time")[:datetime]
      dt = Time.zone.parse(datetime)

      self.observ_date = dt.to_date
      if datetime.include?("T")
        self.start_time = dt.strftime("%R") # = %H:%M
      end

      self.protocol = page.at_xpath("//div[contains(@title, 'Protocol:')]/span[2]").text

      duration = page.at_xpath("//span[contains(@title, 'Duration:')]")&.attr(:title)
      if duration.present?
        md = duration.match(DURATION_REGEX)

        self.duration_minutes = md[1].to_i * 60 + md[2].to_i
      end

      distance = page.at_xpath("//span[contains(@title, 'Distance:')]")&.attr(:title)

      dm = distance&.match(/^Distance:\s*([\d.]+) (.*)$/)
      if dm
        val = dm[1].to_f
        if dm[2] == "mile(s)"
          val = val * 1.609344 # rubocop:disable Style/SelfAssignment
        end

        self.distance_kms = val
      end

      area = page.css("div.Observation-meta-item").text.match(/Area:\s*([\d.]+) ac/)
      if area
        self.area_acres = area[1]
      end
      observers = page.at_xpath("//span[contains(@title, 'Observers:')]")
      if observers
        party = observers[:title].match(/^Observers:\s*(\d+)$/)[1]
        if party != "1"
          self.observers = party
          # self.observers = page.xpath("//dl[dt[text()='Observers:']]/dd").text. TODO: beautify the text
        end
      end

      comments = page.at_xpath("//section[h3[text()='Checklist Comments']]/p[contains(@class, 'u-constrainBody')]")&.text

      unless comments == "N/A"
        self.notes = comments
      end

      complete_text = page.at_xpath("//*[@aria-controls='status-info']/span[contains(@class, 'Badge-label')]")&.text

      self.complete =
        if complete_text == "Complete"
          true
        elsif complete_text == "Incomplete"
          false
        end

      self.location_string = page.at_xpath("//div[@data-locationname]").text

      self.observations = []

      page.css("main ol li[data-observation]").each do |row|
        observations << {
          name: row.at_css("section .Observation-species .Heading .Heading-main").text&.strip,
          species_code: row.at_css("section")[:id],
          count: row.css("div.Observation-numberObserved span span")[1].text,
          comments: row.at_css("div.Observation-comments p")&.text,
          obs_id: row.at_css("button.Observation-tools-item")["data-obsid"],
        }
      end

      self
    end
  end
end
