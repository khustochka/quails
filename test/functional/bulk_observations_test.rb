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
  end

end