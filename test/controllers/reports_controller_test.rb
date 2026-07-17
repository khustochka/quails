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
    o = create(:observation, card: create(:card, observ_date: Time.current, post_core: p.post_core))
    create(:image, observations: [o])

    login_as_admin
    get :this_day
    assert_response :success
  end

  test "admin sees reports/more_than_year" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :more_than_year, params: { days: 365 }
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
    get :compare, params: { loc1: "kyiv", loc2: "brovary" }
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

  test "admin sees reports/stats filtered by location" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :stats, params: { locus: "usa" }
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
    assert_response :success
  end

  test "correct redirect for reports/more_than_year" do
    create(:observation, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, card: create(:card, observ_date: "2009-06-18"))
    login_as_admin
    get :more_than_year, params: { sort: :days }
    assert_redirected_to reports_more_than_year_path(days: 365, sort: :days)
  end

  test "charts work" do
    login_as_admin
    get :charts
    assert_response :success
  end

  test "charts work with years parameter" do
    login_as_admin
    get :charts, params: { years: "2015..2017" }
    assert_response :success
  end

  test "admin sees reports/insights" do
    post = create(:post)
    obs = create(:observation, card: create(:card, observ_date: "2007-06-18", post_core: post.post_core))
    create(:image, observations: [obs])
    create(:comment)

    login_as_admin
    get :insights

    assert_response :success
    assert_template "insights"
  end

  test "admin sees reports/year_contest" do
    sp = taxa(:saxola)
    create(:observation, taxon: sp, card: create(:card, observ_date: "2011-01-01"))

    login_as_admin
    get :year_contest, params: { year: 2011 }

    assert_response :success
    assert_equal [Species.find(sp.species_id)], assigns(:result)
  end

  test "reports/year_contest defaults to the current year" do
    login_as_admin
    get :year_contest

    assert_response :success
    assert_equal Settings.current_year, assigns(:year)
  end

  test "reports/more_than_year sorted by days lists the longest gap first" do
    sp1 = taxa(:saxola)
    sp2 = taxa(:jyntor)
    create(:observation, taxon: sp1, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, taxon: sp1, card: create(:card, observ_date: "2012-06-18"))
    create(:observation, taxon: sp2, card: create(:card, observ_date: "2007-06-18"))
    create(:observation, taxon: sp2, card: create(:card, observ_date: "2009-06-18"))

    login_as_admin
    get :more_than_year, params: { days: 365, sort: :days }

    assert_response :success
    days = assigns(:list).pluck(:days)
    assert_equal days.sort.reverse, days
  end

  test "reports/compare redirects to the default loci when none are given" do
    login_as_admin
    get :compare

    assert_redirected_to reports_compare_path(loc1: "kyiv", loc2: "brovary")
  end

  test "reports/compare keeps the given locus when only one is provided" do
    login_as_admin
    get :compare, params: { loc1: "usa" }

    assert_redirected_to reports_compare_path(loc1: "usa", loc2: "brovary")
  end

  test "reports/compare of loci in different countries compares over all cards" do
    login_as_admin
    get :compare, params: { loc1: "kyiv", loc2: "new_york_city" }

    assert_response :success
    assert_equal loci(:kyiv), assigns(:loc1)
    assert_equal loci(:nyc), assigns(:loc2)
  end

  test "reports/this_day accepts an explicit day" do
    obs = create(:observation, card: create(:card, observ_date: "2009-06-18"))
    create(:image, observations: [obs])

    login_as_admin
    get :this_day, params: { day: "06-18" }

    assert_response :success
    assert_equal "06", assigns(:month)
    assert_equal "18", assigns(:day)
  end

  test "reports/uptoday filtered by locus" do
    login_as_admin
    get :uptoday, params: { locus: "kyiv" }

    assert_response :success
    assert_equal loci(:kyiv), assigns(:locus)
  end

  test "reports/uptoday accepts an explicit day" do
    login_as_admin
    get :uptoday, params: { day: "06-18" }

    assert_response :success
    assert_equal Date.new(Time.current.year, 6, 18), assigns(:this_day)
  end

  test "clear_cache enqueues the job and redirects" do
    login_as_admin

    assert_difference -> { GoodJob::Job.where(job_class: "ClearCacheJob").count }, 1 do
      post :clear_cache
    end
    assert_redirected_to reports_path
  end

  test "send_test_email enqueues the job and redirects" do
    login_as_admin

    assert_difference -> { GoodJob::Job.where(job_class: "EmailTestJob").count }, 1 do
      post :send_test_email
    end
    assert_redirected_to reports_path
  end

  test "server_error raises" do
    login_as_admin

    assert_raise(RuntimeError) { get :server_error }
  end
end
