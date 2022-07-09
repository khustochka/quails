# frozen_string_literal: true

require "test_helper"
require "ebird/ebird_checklist_meta"

class EbirdPreloadJobTest < ActiveJob::TestCase
  test "form for importing checklists contains authenticity token" do
    ActionController::Base.allow_forgery_protection = true
    job = EbirdPreloadJob.new
    checklist = EbirdChecklistMeta.new(
      ebird_id: "S108423956",
      time: "29 Apr 2022 6:27 PM",
      location: "Cordite Trail",
      county: "Winnipeg",
      state_prov: "Manitoba"
    )
    html = job.render_template(Time.zone.now, [checklist])
    doc = Nokogiri::HTML(html)
    assert doc.css("form input[name=authenticity_token]").present?, "Authenticity token not rendered in the form"
  ensure
    ActionController::Base.allow_forgery_protection = false
  end
end
