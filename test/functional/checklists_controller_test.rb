require 'test_helper'

class ChecklistsControllerTest < ActionController::TestCase

  test 'shows checklist for Ukraine' do
    get :show, slug: 'ukraine'
    assert_response :success
    assigns(:checklist).should_not be_blank
  end

  test 'do not show checklist for other countries' do
    assert_raises(ActionController::RoutingError) { get :show, slug: 'usa' }
  end

end