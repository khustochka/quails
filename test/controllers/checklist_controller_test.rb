require 'test_helper'

class ChecklistControllerTest < ActionController::TestCase

  test 'shows checklist for Ukraine' do
    LocalSpecies.create(locus: loci(:ukraine), species: species(:pasdom))
    get :show, country: 'ukraine'
    assert_response :success
    assert assigns(:checklist).present?
    assert_select "a[href='#{species_path(species(:pasdom))}']"
  end

  test 'edit checklist for Ukraine' do
    login_as_admin
    LocalSpecies.create(locus: loci(:ukraine), species: species(:pasdom))
    get :edit, country: 'ukraine'
    assert_response :success
    assert assigns(:checklist).present?
    assert_select "input"
  end

  test 'edit checklist should be protected' do
    assert_raise(ActionController::RoutingError) {
      get :edit, country: 'ukraine'
    }
  end

  test 'do not show checklist for unknown countries' do
    assert_raise(ActionController::UrlGenerationError) { get :show, country: 'georgia' }
  end

  test 'do not show checklist for other countries' do
    assert_raise(ActiveRecord::RecordNotFound) { get :show, country: 'usa' }
  end

  #test 'save checklist for Ukraine' do
  #  login_as_admin
  #  get :save, country: 'ukraine'
  #  assert_response :success
  #end

end
