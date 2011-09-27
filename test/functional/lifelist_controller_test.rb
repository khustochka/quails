require 'test_helper'

class LifelistControllerTest < ActionController::TestCase

  setup do
    @obs = [
        FactoryGirl.create(:observation, :species => seed(:pasdom), :observ_date => "2010-06-20", :locus => seed(:new_york)),
        FactoryGirl.create(:observation, :species => seed(:melgal), :observ_date => "2010-06-18"),
        FactoryGirl.create(:observation, :species => seed(:anapla), :observ_date => "2009-06-18"),
        FactoryGirl.create(:observation, :species => seed(:anacly), :observ_date => "2007-07-18", :locus => seed(:brovary)),
        FactoryGirl.create(:observation, :species => seed(:embcit), :observ_date => "2009-08-09", :locus => seed(:kherson))
    ]
  end

  test "show lifelist ordered by count" do
    get :by_count
    assert_response :success
    assert_select '#main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href=#{lifelist_path}]"
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :only_path => true)}]"
      assert_select "a[href=#{url_for(:action => :by_count, :only_path => true)}]", false
    end
  end

  test "show lifelist ordered by taxonomy" do
    get :by_taxonomy
    assert_response :success
    assert_select '#main' do
      assert_select 'h5' # should show order/family headings
      assert_select "a[href=#{lifelist_path}]"
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :only_path => true)}]", false
      assert_select "a[href=#{url_for(:action => :by_count, :only_path => true)}]"
    end
  end

  test "show default lifelist" do
    get :default
    assert_response :success
    assert_select '#main' do
      assert_select 'h5' # should show "First time seen in..."
      assert_select "a[href=#{lifelist_path}]", false
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :only_path => true)}]"
      assert_select "a[href=#{url_for(:action => :by_count, :only_path => true)}]"
    end
  end

  test "show year list by date" do
    get :default, :year => 2009
    assert_response :success
    assert_select '#main' do
      assert_select 'h5', false # should not show "First time seen in..."
      assert_select "a[href=#{lifelist_path(:year => 2009)}]", false
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :year => 2009, :only_path => true)}]"
      assert_select "a[href=#{url_for(:action => :by_count, :year => 2009, :only_path => true)}]"

      assert_select "li.lifer_row" do |els|
        els.each { |el| assert_select el, 'time', /2009/, 'Found items not matching the proper year' } # list only shows dates from 2009
      end
    end
  end

  test "show year list by count" do
    get :by_count, :year => 2009
    assert_response :success
    assert_select '#main' do
      assert_select 'h5', false # should not splice the list
      assert_select "a[href=#{lifelist_path(:year => 2009)}]"
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :year => 2009, :only_path => true)}]"
      assert_select "a[href=#{url_for(:action => :by_count, :year => 2009, :only_path => true)}]", false
    end
  end

  test "show year list by taxonomy" do
    get :by_taxonomy, :year => 2009
    assert_response :success
    assert_select '#main' do
      assert_select 'h5' # should show order/family headings
      assert_select "a[href=#{lifelist_path(:year => 2009)}]"
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :year => 2009, :only_path => true)}]", false
      assert_select "a[href=#{url_for(:action => :by_count, :year => 2009, :only_path => true)}]"

      assert_select "li.lifer_row" do |els|
        els.each { |el| assert_select el, 'time', /2009/, 'Found items not matching the proper year' } # list only shows dates from 2009
      end
    end
  end

  #test "show location list" do
  #  get :lifelist, :locus => 'new_york'
  #  assert_response :success
  #  assert_select 'a.sp_link'
  #end
  #
  #test "show lifelist filtered by year and location" do
  #  get :lifelist, :locus => 'brovary', :year => 2007
  #  assert_response :success
  #  assert_select 'a.sp_link'
  #end
  #
  #test "show lifelist filtered by year and super location" do
  #  get :lifelist, :locus => 'ukraine', :year => 2009
  #  assert_response :success
  #  assert_select 'a.sp_link'
  #end

  test "lifelist links filter out invalid parameters" do
    get :by_count, :year => 2009, :zzz => 'ooo'
    assert_response :success
    assert_select '#main' do
      assert_select "a[href=#{lifelist_path(:year => 2009)}]"
      assert_select "a[href=#{url_for(:action => :by_taxonomy, :year => 2009, :only_path => true)}]"
      assert_select "a[href=#{url_for(:action => :by_count, :year => 2009, :only_path => true)}]", false
    end
  end

end
