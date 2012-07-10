require 'test_helper'

class ChecklistsControllerTest < ActionController::TestCase

  test 'shows checklist for Ukraine' do
    get :show, slug: 'ukraine'
    assert_response :success
    expect(assigns(:checklist)).not_to be_blank
  end

  test 'do not show checklist for other countries' do
    expect { get :show, slug: 'usa' }.to raise_error(ActionController::RoutingError)
  end

end