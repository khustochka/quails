require 'test_helper'

class ChecklistsControllerTest < ActionController::TestCase

  test 'shows checklist for Ukraine' do
    get :show, slug: 'ukraine'
    assert_response :success
    assert_present assigns(:checklist)
  end

  test 'do not show checklist for other countries' do
    assert_raise(ActionController::RoutingError) { get :show, slug: 'usa' }
  end

end