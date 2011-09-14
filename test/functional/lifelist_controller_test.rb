require 'test_helper'

class LifelistControllerTest < ActionController::TestCase

  setup do
    @obs = [
        Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20", :locus => Locus.find_by_code!('new_york')),
        Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18"),
        Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18"),
        Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18", :locus => Locus.find_by_code!('brovary')),
        Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09", :locus => Locus.find_by_code!('kherson'))
    ]
  end

  test "show lifelist ordered by count" do
    get :count
    assert_response :success
  end

  test "show lifelist ordered by taxonomy" do
    get :taxonomy
    assert_response :success
  end

  test "show default lifelist" do
    get :default
    assert_response :success
  end

  #test "show year list" do
  #  get :lifelist, :year => 2009
  #  assert_response :success
  #  assert_select 'a.sp_link'
  #end
  #
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

end
