require 'test_helper'

class ResearchControllerTest < ActionController::TestCase
  test "admin sees Research/index" do
    login_as_admin
    get :index
    assert_response :success
    assert_template 'index'
  end

  test "user does not see Research/index" do
    assert_raise(ActionController::RoutingError) { get :index }
    #assert_response 404
  end

  test "admin sees Research/day" do
    p = create(:post)
    o = create(:observation, card: create(:card, observ_date: Time.now, post: p))
    create(:image, observations: [o])

    login_as_admin
    get :day
    assert_response :success
  end

  test "admin sees Research/more_than_year" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :more_than_year, params: {days: 365}
    assert_response :success
  end

  test "admin sees Research/topicture" do
    o = create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:image, observations: [o])
    login_as_admin
    get :topicture
    assert_response :success
  end

  test "admin sees Research/compare" do
    login_as_admin
    get :compare, params: {loc1: 'kiev', loc2: 'brovary'}
    assert_response :success
  end

  test "admin sees Research/by_countries" do
    login_as_admin
    get :by_countries
    assert_response :success
  end

  test "admin sees Research/uptoday" do
    login_as_admin
    get :uptoday
    assert_response :success
  end

  test "admin sees Research/stats" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :stats
    assert_response :success
  end

  test "admin sees Research/voices" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"), voice: true)
    create(:observation, card: create(:card, observ_date: "2009-06-18"), voice: false)
    create(:observation, card: create(:card, observ_date: "2009-06-18"), voice: false, taxon: taxa(:hirrus))
    login_as_admin
    get :voices
    assert_response :success
  end

  test "admin sees Research/environment" do
    login_as_admin
    get :environ
    assert_response :success
    assert_template 'environ'
  end

  test "month targets work" do
    login_as_admin
    get :month_targets
  end
end
