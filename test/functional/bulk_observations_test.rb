require 'test_helper'

class BulkObservationsTest < ActionController::TestCase
  tests ObservationsController

  context '#bulksave' do

    should 'successfully save several observations' do
      login_as_admin
      assert_difference('Observation.count', 3) do
        post :bulksave, {:c => {:locus_id => Locus.find_by_code('brovary').id,
                                :observ_date => '2010-05-05', :mine => true},
                         :o => [{:species_id => 2},
                                {:species_id => 4},
                                {:species_id => 6}]
        }
      end
      assert_response :success
      assert_not_nil Observation.find_by_species_id(2)
      assert_not_nil Observation.find_by_species_id(4)
      assert_not_nil Observation.find_by_species_id(6)
    end

    should 'return proper ids after saving several observations' do
      login_as_admin
      post :bulksave, {:c => {:locus_id => Locus.find_by_code('brovary').id,
                              :observ_date => '2010-05-05', :mine => true},
                       :o => [{:species_id => 2},
                              {:species_id => 4},
                              {:species_id => 6}]
      }
      assert_response :success
      assert_equal Mime::JSON, response.content_type
      result = JSON.parse(response.body)
      assert_equal 'OK', result['result']
      expected = [2, 4, 6].map { |el| Observation.find_by_species_id(el).id }
      assert_equal expected, result['data'].map { |el| el['id'] }
    end

    should 'return error for incorrect common parameters (date, locus)' do
      login_as_admin
      assert_difference('Observation.count', 0) do
        post :bulksave, {:c => {:locus_id => '',
                                :observ_date => '', :mine => true},
                         :o => [{:species_id => 2},
                                {:species_id => 4},
                                {:species_id => 6}]
        }
      end
      assert_response :success
      assert_equal Mime::JSON, response.content_type
      result = JSON.parse(response.body)
      assert_equal 'Error', result['result']
      assert_equal({"observ_date"=>["can't be blank"], "locus_id"=>["can't be blank"]}, result['data'])
      assert_nil Observation.find_by_species_id(2)
      assert_nil Observation.find_by_species_id(4)
      assert_nil Observation.find_by_species_id(6)
    end

    should 'return error for incorrect observation parameter (species_id)' do
      login_as_admin
      assert_difference('Observation.count', 0) do
        post :bulksave, {:c => {:locus_id => Locus.find_by_code('brovary').id,
                                :observ_date => '2010-05-05', :mine => true},
                         :o => [{:species_id => ''}]
        }
      end
      assert_response :success
      assert_equal Mime::JSON, response.content_type
      result = JSON.parse(response.body)
      assert_equal 'OK', result['result']
      assert_equal({"species_id"=>["can't be blank"]}, result['data'][0]['msg'])
    end

  end

end