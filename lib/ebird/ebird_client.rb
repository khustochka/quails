# frozen_string_literal: true

require "ebird/ebird_checklist_meta"

class EbirdClient

  def initialize
    @agent = Mechanize.new
    @authenticated = false
  end

  def authenticate
    page = @agent.get("https://ebird.org/")
    page = page.link_with(text: "Sign in").click
    form = page.form
    form.username = Settings.ebird_user.name
    form.password = Settings.ebird_user.password
    page = @agent.submit(form)

    @authenticated = page.xpath("//a[contains(@class, 'HeaderEbird-link')]/span[contains(text(),'(#{Settings.ebird_user.name})')]").any?
  end

  # def get_checklists_for_date(date)
  #   page = @agent.get("https://ebird.org/eBirdReports?cmd=SubReport&currentRow=1&rowsPerPage=1000&sortBy=date&order=desc")
  #   list_rows = page.xpath("//tr[td[1][starts-with(text(), '#{date}')]]")
  #   list_rows.map do |row|
  #     ebird_id = row.xpath("td/a[text()='View or edit']").first[:href].scan(/checklist\/(.*)\/?$/)[0][0]
  #     {
  #         time: row.xpath("td[1]").text,
  #         location: row.xpath("td[2]").text,
  #         county: row.xpath("td[3]").text,
  #         state_prov: row.xpath("td[4]").text,
  #         ebird_id: ebird_id,
  #         card: Card.find_by_ebird_id(ebird_id)
  #     }
  #   end.reverse
  # end

  # def get_checklists_after_date(date)
  #   page = @agent.get("https://ebird.org/eBirdReports?cmd=SubReport&currentRow=1&rowsPerPage=1000&sortBy=date&order=desc")
  #   list_rows = page.xpath("//div[@id='content']/table/tr[starts-with(@class, 'spec')]")
  #   list_rows.to_a.take_while do |row|
  #     row.xpath("./td[1]").text >= date.to_s
  #   end.
  #       map do |row|
  #         ebird_id = row.xpath("./td/a[text()='View or edit']").first[:href].scan(/checklist\/(.*)\/?$/)[0][0]
  #         unless Card.exists?(ebird_id: ebird_id)
  #           {
  #               time: row.xpath("./td[1]").text,
  #               location: row.xpath("./td[2]").text,
  #               county: row.xpath("./td[3]").text,
  #               state_prov: row.xpath("./td[4]").text,
  #               ebird_id: ebird_id,
  #               card: Card.find_by_ebird_id(ebird_id)
  #           }
  #         else
  #           nil
  #         end
  #   end.compact.reverse
  # end

  def get_unsubmitted_checklists
    page = @agent.get("https://ebird.org/mychecklists?currentRow=1&rowsPerPage=100&sortBy=date&order=desc")
    list_rows = page.xpath("//ol[@id='place-species-observed-results']/li")
    first100 = list_rows.to_a.take(100).map do |row|
      ebird_id = row[:id].scan(/checklist-(.*)$/)[0][0]
      EbirdChecklistMeta.new(
          ebird_id: ebird_id,
          time: row.xpath("./div[@class='ResultsStats-title']").text.strip.gsub(/\s+/, " "),
          location: row.xpath("./div[@class='ResultsStats-details']/div/div/div[1]/div[contains(@class, 'ResultsStats-details-location')]").first.text,
          county: row.xpath("./div[@class='ResultsStats-details']/div/div/div[2]/div[contains(@class, 'ResultsStats-details-county')]").first.text,
          state_prov: row.xpath("./div[@class='ResultsStats-details']/div/div/div[3]/div[contains(@class, 'ResultsStats-details-stateCountry')]").first.text
      )
    end
    ebird_ids = first100.map(&:ebird_id)
    cards = Card.where(ebird_id: ebird_ids)
    posted_ids = cards.pluck(:ebird_id)
    first100.delete_if {|list| list.ebird_id.in?(posted_ids)}
  end

  def fetch_checklist(checklist)
    authenticate unless @authenticated
    @agent.get(checklist.url)
  end

end
