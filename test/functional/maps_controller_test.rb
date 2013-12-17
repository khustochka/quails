require 'test_helper'

class MapsControllerTest < ActionController::TestCase

  test "admin sees Map" do
    login_as_admin
    get :show
    assert_response :success
  end

  test "admin sees edit map" do
    login_as_admin
    get :edit
    assert_response :success
  end

  test "properly find observations with spots" do
    obs1 = create(:observation, card: create(:card, observ_date: '2010-07-24'))
    obs2 = create(:observation, card: create(:card, observ_date: '2011-07-24'))
    create(:spot, observation: obs1)
    create(:spot, observation: obs2)
    login_as_admin
    get :observations, format: :json, q: {observ_date: '2010-07-24'}
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['json']
    assert_equal 1, result.size
    result[0].assert_valid_keys('id', 'spots')
    assert_equal 1, result[0]['spots'].size
  end

  test 'return observation search results sorted by taxonomy' do
    login_as_admin
    # Try to create observation in random order
    obss = [create(:observation, species: seed(:denmaj)),
            create(:observation, species: seed(:pasdom)),
            create(:observation, species: seed(:anacre))]
    get :observations, q: {observ_date: obss[0].card.observ_date.iso8601}, format: 'json'
    assert_response :success
    result = JSON.parse(response.body)['json']
    assert_equal 3, result.size
  end

  test 'return observation search results that include Avis incognita in JSON' do
    login_as_admin
    observation = create(:observation, species_id: 0)
    get :observations, q: {observ_date: observation.card.observ_date.iso8601}, format: 'json'
    assert_response :success
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['json']
    assert_equal 1, result.size
  end

end
