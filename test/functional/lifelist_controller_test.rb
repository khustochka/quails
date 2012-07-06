require 'test_helper'

class LifelistControllerTest < ActionController::TestCase

  setup do
    @obs = [
        create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york)),
        create(:observation, species: seed(:melgal), observ_date: "2010-06-18", locus: seed(:new_york)),
        create(:observation, species: seed(:anapla), observ_date: "2009-06-18", locus: seed(:new_york)),
        create(:observation, species: seed(:anacly), observ_date: "2007-07-18"),
        create(:observation, species: seed(:embcit), observ_date: "2009-08-09", locus: seed(:kherson))
    ]
  end

  test "show lifelist ordered by taxonomy" do
    get :default, sort: 'by_taxonomy'
    assert_response :success
    assert_select '.main' do
      assert_select 'h5' # should show order/family headings
      assert_select "a[href=#{lifelist_path}]"
      assert_select "a[href=#{url_for(sort: :by_taxonomy, only_path: true)}]", false
    end
  end

  test "show default lifelist" do
    get :default
    assert_response :success
    assert_select '.main' do
      assert_select 'h5' # should show "First time seen in..."
      assert_select "a[href=#{lifelist_path}]", false
      assert_select "a[href=#{url_for(sort: :by_taxonomy, only_path: true)}]"
    end
  end

  test "show year list by date" do
    get :default, year: 2009
    assert_response :success
    lifers = assigns(:lifelist)
    lifers.map { |s| s.first_seen_date.year }.uniq.should eq([2009])
    assert_select '.main' do
      assert_select 'h5', false # should not show "First time seen in..."
      assert_select "a[href=#{lifelist_path(year: 2009)}]", false
      assert_select "a[href=#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}]"
    end
  end

  test "show year list by taxonomy" do
    get :default, sort: 'by_taxonomy', year: 2009
    assert_response :success
    lifers = assigns(:lifelist)
    lifers.map { |s| s.first_seen_date.year }.uniq.should eq([2009])
    assert_select '.main' do
      assert_select 'h5' # should show order/family headings
      assert_select "a[href=#{lifelist_path(year: 2009)}]"
      assert_select "a[href=#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}]", false
    end
  end

  test "show location list" do
    get :default, locus: 'new_york'
    assert_response :success
    lifers = assigns(:lifelist)
    lifers.size.should eq(3)
  end

  test "show lifelist filtered by year and location" do
    get :default, locus: 'new_york', year: 2009
    assert_response :success
    lifers = assigns(:lifelist)
    lifers.size.should eq(1)
    lifers.map { |s| s.first_seen_date.year }.uniq.should eq([2009])
  end

  test "show lifelist filtered by super location" do
    get :default, locus: 'ukraine'
    lifers = assigns(:lifelist)
    lifers.size.should eq(2)
  end

  test "not allowed locus fails" do
    assert_raise ActiveRecord::RecordNotFound do
      get :default, locus: 'sumy_obl'
    end
    # assert_response :not_found
  end

  test "lifelist links filter out invalid parameters" do
    get :default, sort: 'by_taxonomy', year: 2009, zzz: 'ooo'
    assert_response :success
    assert_select '.main' do
      assert_select "a[href=#{lifelist_path(year: 2009)}]"
      assert_select "a[href=#{url_for(sort: :by_taxonomy, year: 2009, only_path: true)}]", false
      assert_select "a[href=#{url_for(sort: :by_taxonomy, year: 2010, only_path: true)}]"
    end
  end

  test "show Advanced Lifelist" do
    get :advanced
    assert_response :success
  end

  test 'empty lifelist shows no list' do
    get :default, year: 1899
    assert_select '.main' do
      assert_select 'ol', false
      assert_select 'p', 'No species', 'No proper message found (saying no species in the list)'
    end
  end

end
