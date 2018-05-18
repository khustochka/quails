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

  def get_checklists_for_date(date)
    page = @agent.get("https://ebird.org/eBirdReports?cmd=SubReport&currentRow=1&rowsPerPage=1000&sortBy=date&order=desc")
    list_rows = page.xpath("//tr[td[1][starts-with(text(), '#{date}')]]")
    list_rows.map do |row|
      {
          time: row.xpath("td[1]").text,
          location: row.xpath("td[2]").text,
          county: row.xpath("td[3]").text,
          state_prov: row.xpath("td[4]").text,
          ebird_id: row.xpath("td/a[text()='View or edit']").first[:href].scan(/checklist\/(.*)\/?$/)[0][0],
      }
    end
  end

  def get_checklist(ebird_id)
    url = "https://ebird.org/view/checklist/#{ebird_id}"
    @agent.get(url)
  end

end
