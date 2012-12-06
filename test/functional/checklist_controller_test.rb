require 'test_helper'

class ChecklistControllerTest < ActionController::TestCase

  test 'edit checklist for Ukraine' do
    login_as_admin
    get :edit, country: 'ukraine'
    assert_response :success
    assert_present assigns(:checklist)
  end

  #test 'save checklist for Ukraine' do
  #  login_as_admin
  #  get :save, country: 'ukraine'
  #  assert_response :success
  #end

end
