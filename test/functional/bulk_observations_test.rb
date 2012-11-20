require 'test_helper'

class BulkObservationsTest < ActionController::TestCase
  tests ObservationsController

  CANT_BE_BLANK = I18n.t('errors.messages.blank')

  test 'successful Observations bulk save' do
    login_as_admin
    assert_difference('Observation.count', 3) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                      o: [{species_id: 2, biotope: 'city'},
                              {species_id: 4, biotope: 'city'},
                              {species_id: 6, biotope: 'city'}]
      }
    end
    assert_response :created
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal 3, result.size
    assert_equal ['id'], result[0].keys
    assert_not_nil Observation.find_by_species_id(2)
    assert_not_nil Observation.find_by_species_id(4)
    assert_not_nil Observation.find_by_species_id(6)
  end

  test 'Observations bulk save returns error if no observations provided' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true}
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal({"errors"=>{"base"=>["provide at least one observation"]}}, result)
  end

  test 'Observations bulk save returns error for incorrect common parameters (date, locus)' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: '',
                              observ_date: '', mine: true},
                       o: [{species_id: 2, biotope: 'city'},
                              {species_id: 4, biotope: 'city'},
                              {species_id: 6, biotope: 'city'}]
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal({"errors"=>{"observ_date"=>[CANT_BE_BLANK], "locus_id"=>[CANT_BE_BLANK]}}, result)
  end

  test 'Observations bulk save combines errors for incorrect common parameters and zero observations' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: '',
                              observ_date: '', mine: true}
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal({"errors"=>{"observ_date"=>[CANT_BE_BLANK],
                  "locus_id"=>[CANT_BE_BLANK],
                  "base"=>["provide at least one observation"]}}, result)
  end

  test 'Observations bulk save returns error for incorrect observation parameter (species_id)' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                       o: [{species_id: '', biotope: 'city'}]
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['errors']
    assert_equal({"species_id"=>[CANT_BE_BLANK]}, result['observs'][0])
  end

  test 'Observations bulk save does not save the bunch if any observation is wrong' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                       o: [{species_id: '', biotope: 'city'}, {species_id: 2, biotope: 'city'}]
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['errors']
    assert_equal({"species_id"=>[CANT_BE_BLANK]}, result['observs'][0])
  end

  test 'successful updating existing and saving new observations' do
    obs = create(:observation, species_id: 2)
    login_as_admin
    assert_difference('Observation.count', 1) do
      post :bulksave, {format: :json,
                       c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                       o: [{id: obs.id, species_id: 4},
                              {species_id: 6, biotope: 'city'}]
      }
    end
    assert_response :success
    assert_nil Observation.find_by_species_id(2)
    assert_not_nil Observation.find_by_species_id(4)
    assert_not_nil Observation.find_by_species_id(6)
  end

  test "get bulk successful" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18")
    login_as_admin
    get :bulk, observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: true
    assert_response :success
    assert_equal 2, assigns(:observations).size
  end

  test "get bulk not mine" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18", mine: false)
    create(:observation, species: seed(:anapla), observ_date: "2010-06-18", mine: false)
    login_as_admin
    get :bulk, observ_date: "2010-06-18", locus_id: seed(:brovary).id, mine: false
    assert_response :success
    assert_equal 2, assigns(:observations).size
  end

  test "get bulk missing parameters" do
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-20", locus: seed(:new_york))
    create(:observation, species: seed(:pasdom), observ_date: "2010-06-18", locus: seed(:new_york))
    create(:observation, species: seed(:melgal), observ_date: "2010-06-18")
    create(:observation, species: seed(:anapla), observ_date: "2009-06-18")
    login_as_admin
    get :bulk, locus_id: seed(:brovary).id
    assert_redirected_to add_observations_path(locus_id: seed(:brovary).id)
  end

  test 'protect bulk with HTTP authentication' do
    assert_raise(ActionController::RoutingError) { get :bulk }
    #assert_response 404
  end

end
