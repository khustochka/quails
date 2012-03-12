require 'test_helper'

class BulkObservationsTest < ActionController::TestCase
  tests ObservationsController

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
    result.size.should == 3
    result[0].keys.should == ['id']
    assert_not_nil Observation.find_by_species_id(2)
    assert_not_nil Observation.find_by_species_id(4)
    assert_not_nil Observation.find_by_species_id(6)
  end
  
  test 'Observations bulk save should return error if no observations provided' do
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

  test 'Observations bulk save should return error for incorrect common parameters (date, locus)' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: '',
                              observ_date: '', mine: true},
                       o: [{species_id: 2, biotope: 'city'},
                              {species_id: 4, biotope: 'city'},
                              {species_id: 6, biotope: 'city'}],
                       hl: 'en'
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal({"errors"=>{"observ_date"=>["can't be blank"], "locus_id"=>["can't be blank"]}}, result)
  end

  test 'Observations bulk save should combine errors for incorrect common parameters and zero observations' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: '',
                              observ_date: '', mine: true},
          hl: 'en'
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)
    assert_equal({"errors"=>{"observ_date"=>["can't be blank"],
                  "locus_id"=>["can't be blank"],
                  "base"=>["provide at least one observation"]}}, result)
  end

  test 'Observations bulk save should return error for incorrect observation parameter (species_id)' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                       o: [{species_id: '', biotope: 'city'}],
                       hl: 'en'
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['errors']
    assert_equal({"species_id"=>["can't be blank"]}, result['observs'][0])
  end

  test 'Observations bulk save should not save the bunch if any observation is wrong' do
    login_as_admin
    assert_difference('Observation.count', 0) do
      post :bulksave, {format: :json,
                        c: {locus_id: seed(:brovary).id,
                              observ_date: '2010-05-05', mine: true},
                       o: [{species_id: '', biotope: 'city'}, {species_id: 2, biotope: 'city'}],
                       hl: 'en'
      }
    end
    assert_response :unprocessable_entity
    assert_equal Mime::JSON, response.content_type
    result = JSON.parse(response.body)['errors']
    assert_equal({"species_id"=>["can't be blank"]}, result['observs'][0])
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

end