# frozen_string_literal: true

require "test_helper"

class LogbookControllerTest < ActionController::TestCase
  test "user cannot see logbook" do
    assert_raise(ActionController::RoutingError) { get :index }
  end

  test "admin is prompted to enable lists when none are selected" do
    login_as_admin
    get :index

    assert_response :success
    assert_select "a[href='/settings/logbook']", text: "Enable some in settings."
  end

  test "admin sees latest entries" do
    LogbookSetting.create!(locus: nil, life: true, year: true)
    LogbookSetting.create!(locus: loci(:ukraine), life: true)
    obs = create(:observation, card: create(:card, observ_date: 3.days.ago.to_date))

    login_as_admin
    get :index

    assert_response :success
    date = 3.days.ago.to_date
    assert_select "dl.logbook dt time[datetime='#{date.iso8601}']", text: date.strftime("%-d %b %Y")
    assert_select "dl.logbook dd li", text: "New lifer (1), new species in Ukraine (1): #{obs.species.name_en}"
  end

  test "admin sees entries of a year" do
    LogbookSetting.create!(locus: nil, life: true, year: true)
    create(:observation, card: create(:card, observ_date: "2023-05-01"))
    create(:observation, card: create(:card, observ_date: "2024-05-01"))
    create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2024-05-01"))

    login_as_admin
    get :index, params: { year: 2024 }

    assert_response :success
    assert_select "ul.logbook-years span", text: "2024"
    assert_select "dl.logbook dd li", text: "New lifer (2): Barn Swallow"
    assert_select "dl.logbook dd li", text: "New species for 2024 (1): House Sparrow"
  end

  test "invalid year is rejected" do
    login_as_admin
    assert_raise(ActionController::RoutingError) { get :index, params: { year: "abc" } }
  end
end
