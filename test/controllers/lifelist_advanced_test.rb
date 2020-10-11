# frozen_string_literal: true

require 'test_helper'

class LifelistAdvancedTest < ActionController::TestCase
  tests LifelistController

  setup do
    @obs = [
        create(:observation, taxon: taxa(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:hirrus), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:bomgar), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
        create(:observation, taxon: taxa(:saxola), card: create(:card, observ_date: "2007-07-18")),
        create(:observation, taxon: taxa(:jyntor), card: create(:card, observ_date: "2009-08-09", locus: loci(:brovary)))
    ]
  end

  test "show Advanced Lifelist" do
    get :advanced
    assert_response :success
  end

  test "show lifelist ordered by count" do
    get :advanced, params: {sort: 'count'}
    assert_response :success
    assert_select '.main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href='#{advanced_list_path}']"
      assert_select "a[href='#{url_for(sort: :class, only_path: true)}']"
      assert_select "a[href='#{url_for(sort: :count, only_path: true)}']", false
    end
  end

  test "show lifelist ordered by taxonomy" do
    get :advanced, params: {sort: 'class'}
    assert_response :success
    assert_select '.main' do
      assert_select "a[href='#{advanced_list_path}']"
      assert_select "a[href='#{url_for(sort: :class, only_path: true)}']", false
      assert_select "a[href='#{url_for(sort: :count, only_path: true)}']"
    end
  end

  test "show year list by count" do
    get :advanced, params: {sort: 'count', year: 2009}
    assert_response :success
    assert_select '.main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href='#{advanced_list_path(year: 2009)}']"
    end
  end

  test "show location list" do
    get :advanced, params: {locus: 'usa'}
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 3, lifers.size
  end

  test "show lifelist filtered by year and location" do
    get :advanced, params: {locus: 'usa', year: 2009}
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 1, lifers.size
    assert_equal [2009], lifers.map { |s| s.first_seen.observ_date.year }.uniq
  end

  test "lifelist should show correct link to localized page (including filters)" do
    get :advanced, params: {locus: 'usa', year: 2009}
    assert_response :success
    assert_select "a[href='#{advanced_list_path(locus: 'usa', year: 2009, locale: :en)}']"
  end

end
