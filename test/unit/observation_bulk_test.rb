require 'test_helper'

class ObservationBulkTest < ActiveSupport::TestCase

  test 'successful observation bulk save' do
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:brovary).id,
        :observ_date => '2010-05-05', :mine => true},
      :o => [{:species_id => 2},
        {:species_id => 4},
        {:species_id => 6}]
    })
    assert_difference('Observation.count', 3) do
      bulk.save
    end
    bulk.errors.should be_blank
  end

  test 'observation bulk save should return error if no observations provided' do
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:brovary).id,
        :observ_date => '2010-05-05', :mine => true}
    })
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    bulk.errors.should_not be_blank
  end

  test 'Observations bulk save should combine errors for incorrect common parameters and zero observations' do
    bulk = ObservationBulk.new({:c => {:locus_id => '', :observ_date => '', :mine => true}})
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    err = bulk.errors
    err["observ_date"].should == ["can't be blank"]
    err["locus_id"].should == ["can't be blank"]
    err["base"].should == ["provide at least one observation"]
  end

end