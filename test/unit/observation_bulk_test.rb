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

  test 'Observations bulk save should not save the bunch if any observation is wrong' do
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:brovary).id,
                                       :observ_date => '2010-05-05', :mine => true},
                                :o => [{:species_id => ''}, {:species_id => 2}]
                               })
    assert_difference('Observation.count', 0) do
      bulk.save.should be_false
    end
    bulk.errors.should_not be_blank
  end

  test 'Observations bulk save should update observations if id is specified' do
    obs1 = FactoryGirl.create(:observation, :species => seed(:corfru))
    obs2 = FactoryGirl.create(:observation, :species => seed(:cormon))
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:kiev).id,
                                       :observ_date => '2010-11-11', :mine => true},
                                :o => [{:id => obs1.id, :species_id => seed(:cornix).id},
                                       {:id => obs2.id, :notes => 'Voices'}]
                               })
    assert_difference('Observation.count', 0) do
      bulk.save.should be_true
    end
    obs1.reload.species.code.should == 'cornix'
    obs2.reload.notes.should == 'Voices'
  end

  test 'Observations bulk save should both save new and update existing' do
    obs1 = FactoryGirl.create(:observation, :species => seed(:cormon))
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:kiev).id,
                                       :observ_date => '2010-11-11', :mine => true},
                                :o => [{:species_id => seed(:cornix).id},
                                       {:id => obs1.id, :notes => 'Voices'}]
                               })
    assert_difference('Observation.count', 1) do
      bulk.save.should be_true
    end
    bulk[0].species.code.should == 'cornix'
    bulk[1].notes.should == 'Voices'
  end

  test 'Observations bulk save should not save post for invalid bulk' do
    blog = FactoryGirl.create(:post)
    obs1 = FactoryGirl.create(:observation, :species => seed(:corfru))
    obs2 = FactoryGirl.create(:observation, :species => seed(:cormon))
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:kiev).id,
                                       :observ_date => '2010-11-11',
                                       :mine => true,
                                       :post_id => blog.id},
                                :o => [{:id => obs1.id},
                                       {:id => obs2.id, :species_id => nil}]
                               })
    bulk.save.should be_false
    obs1.reload.post.should be_nil
  end

  test 'Observations bulk save should save post for valid bulk' do
    blog = FactoryGirl.create(:post)
    obs1 = FactoryGirl.create(:observation, :species => seed(:corfru))
    obs2 = FactoryGirl.create(:observation, :species => seed(:cormon))
    bulk = ObservationBulk.new({:c => {:locus_id => seed(:kiev).id,
                                       :observ_date => '2010-11-11',
                                       :mine => true,
                                       :post_id => blog.id},
                                :o => [{:id => obs1.id},
                                       {:id => obs2.id}]
                               })
    bulk.save.should be_true
    obs1.reload.post.should_not be_nil
  end

end