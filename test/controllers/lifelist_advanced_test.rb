require 'test_helper'

class LifelistAdvancedTest < ActionController::TestCase
  tests ListsController

  setup do
    @obs = [
        create(:observation, species: seed(:pasdom), card: create(:card, observ_date: "2010-06-20", locus: loci(:nyc))),
        create(:observation, species: seed(:melgal), card: create(:card, observ_date: "2010-06-18", locus: loci(:nyc))),
        create(:observation, species: seed(:anapla), card: create(:card, observ_date: "2009-06-18", locus: loci(:nyc))),
        create(:observation, species: seed(:anacly), card: create(:card, observ_date: "2007-07-18")),
        create(:observation, species: seed(:embcit), card: create(:card, observ_date: "2009-08-09", locus: loci(:brovary)))
    ]
  end

  test "show lifelist ordered by count" do
    get :advanced, sort: 'count'
    assert_response :success
    assert_select '.main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href='#{advanced_list_path}']"
      assert_select "a[href='#{url_for(sort: :class, only_path: true)}']"
      assert_select "a[href='#{url_for(sort: :count, only_path: true)}']", false
    end
  end

  test "show year list by count" do
    get :advanced, sort: 'count', year: 2009
    assert_response :success
    assert_select '.main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href='#{advanced_list_path(year: 2009)}']"
    end
  end

  test "show location list" do
    get :advanced, locus: 'usa'
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 3, lifers.size
  end

  test "show lifelist filtered by year and location" do
    get :advanced, locus: 'usa', year: 2009
    assert_response :success
    lifers = assigns(:lifelist)
    assert_equal 1, lifers.size
    assert_equal [2009], lifers.map { |s| s.first_seen.observ_date.year }.uniq
  end

  test "show Advanced Lifelist" do
    get :advanced
    assert_response :success
  end

end
