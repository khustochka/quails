require 'test_helper'

class SpeciesControllerLifelistTest < ActionController::TestCase
  tests SpeciesController

  test "should show full lifelist" do
    get :lifelist
    assert_response :success
  end

  test "should show year list" do
    get :lifelist, :year => 2009
    assert_response :success
  end

  test "should show location list" do
    get :lifelist, :locus => 'new_york'
    assert_response :success
  end

  test "should show lifelist filtered by year and location" do
    get :lifelist, :locus => 'brovary', :year => 2007
    assert_response :success
  end

  test "should show lifelist filtered by year and super location" do
    get :lifelist, :locus => 'ukraine', :year => 2009
    assert_response :success
  end
end
