# frozen_string_literal: true

require "test_helper"

class ReportsControllerTest < ActionController::TestCase
  test "admin sees reports/index" do
    login_as_admin
    get :index
    assert_response :success
    assert_template "index"
  end

  test "user does not see reports/index" do
    assert_raise(ActionController::RoutingError) { get :index }
    # assert_response 404
  end

  test "admin sees reports/this_day" do
    p = create(:post)
    o = create(:observation, card: create(:card, observ_date: Time.current, post: p))
    create(:image, observations: [o])

    login_as_admin
    get :this_day
    assert_response :success
  end

  test "admin sees reports/more_than_year" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :more_than_year, params: {days: 365}
    assert_response :success
  end

  test "admin sees reports/topicture" do
    o = create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:image, observations: [o])
    login_as_admin
    get :topicture
    assert_response :success
  end

  test "admin sees reports/compare" do
    login_as_admin
    get :compare, params: {loc1: "kiev", loc2: "brovary"}
    assert_response :success
  end

  test "admin sees reports/by_countries" do
    login_as_admin
    get :by_countries
    assert_response :success
  end

  test "admin sees reports/uptoday" do
    login_as_admin
    get :uptoday
    assert_response :success
  end

  test "admin sees reports/stats" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :stats
    assert_response :success
  end

  test "admin sees reports/voices" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"), voice: true)
    create(:observation, card: create(:card, observ_date: "2009-06-18"), voice: false)
    create(:observation, card: create(:card, observ_date: "2009-06-18"), voice: false, taxon: taxa(:hirrus))
    login_as_admin
    get :voices
    assert_response :success
  end

  test "admin sees reports/environment" do
    login_as_admin
    get :environ
    assert_response :success
    assert_template "environ"
  end

  test "month targets work" do
    login_as_admin
    get :month_targets
  end

  test "correct redirect for reports/more_than_year" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :more_than_year, params: {sort: :days}
    assert_redirected_to reports_more_than_year_path(days: 365, sort: :days)
  end

  test "charts work" do
    login_as_admin
    get :charts
  end

  test "charts work with years parameter" do
    login_as_admin
    get :charts, params: {years: "2015..2017"}
  end
end
