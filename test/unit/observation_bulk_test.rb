require 'test_helper'

class ObservationBulkTest < ActiveSupport::TestCase

  test 'successful observation bulk save' do
    bulk = ObservationBulk.new({c: {locus_id: seed(:brovary).id,
                                       observ_date: '2010-05-05', mine: true},
                                o: [{species_id: 2, biotope: 'city'},
                                       {species_id: 4, biotope: 'city'},
                                       {species_id: 6, biotope: 'city'}]
                               })
    assert_difference('Observation.count', 3) do
      bulk.save
    end
    assert bulk.errors.blank?, "Should be no errors"
  end

  test 'observation bulk save returns error if no observations provided' do
    bulk = ObservationBulk.new({c: {locus_id: seed(:brovary).id,
                                       observ_date: '2010-05-05', mine: true}
                               })
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    assert_present bulk.errors
  end

  test 'Observations bulk save combines errors for incorrect common parameters and zero observations' do
    bulk = ObservationBulk.new({c: {locus_id: '', observ_date: '', mine: true}})
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    err = bulk.errors
    assert_equal ["can't be blank"], err["observ_date"]
    assert_equal ["can't be blank"], err["locus_id"]
    assert_equal ["provide at least one observation"], err["base"]
  end

  test 'Observations bulk save does not save the bunch if any observation is wrong' do
    bulk = ObservationBulk.new({c: {locus_id: seed(:brovary).id,
                                       observ_date: '2010-05-05', mine: true},
                                o: [{species_id: ''}, {species_id: 2}]
                               })
    assert_difference('Observation.count', 0) do
      assert_equal false, bulk.save
    end
    assert_present bulk.errors
  end

  test 'Observations bulk save updates observations if id is specified' do
    obs1 = create(:observation, species: seed(:corfru))
    obs2 = create(:observation, species: seed(:cormon))
    bulk = ObservationBulk.new({c: {locus_id: seed(:kiev).id,
                                       observ_date: '2010-11-11', mine: true},
                                o: [{id: obs1.id, species_id: seed(:cornix).id},
                                       {id: obs2.id, notes: 'Voices'}]
                               })
    assert_difference('Observation.count', 0) do
      assert bulk.save
    end
    assert_equal 'cornix', obs1.reload.species.code
    assert_equal 'Voices', obs2.reload.notes
  end

  test 'Observations bulk save both saves new and updates existing' do
    obs1 = create(:observation, species: seed(:cormon))
    bulk = ObservationBulk.new({c: {locus_id: seed(:kiev).id,
                                       observ_date: '2010-11-11', mine: true},
                                o: [{species_id: seed(:cornix).id, biotope: 'city'},
                                       {id: obs1.id, notes: 'Voices', biotope: 'city'}]
                               })
    assert_difference('Observation.count', 1) do
      assert bulk.save
    end
    assert_equal 'cornix', bulk[0].species.code
    assert_equal 'Voices', bulk[1].notes
  end

  test 'Observations bulk save does not save post for invalid bulk' do
    blog = create(:post)
    obs1 = create(:observation, species: seed(:corfru))
    obs2 = create(:observation, species: seed(:cormon))
    bulk = ObservationBulk.new({c: {locus_id: seed(:kiev).id,
                                       observ_date: '2010-11-11',
                                       mine: true,
                                       post_id: blog.id},
                                o: [{id: obs1.id},
                                       {id: obs2.id, species_id: nil}]
                               })
    assert_equal false, bulk.save
    assert_equal nil, obs1.reload.post
  end

  test 'Observations bulk save saves post for valid bulk' do
    blog = create(:post)
    obs1 = create(:observation, species: seed(:corfru))
    obs2 = create(:observation, species: seed(:cormon))
    bulk = ObservationBulk.new({c: {locus_id: seed(:kiev).id,
                                       observ_date: '2010-11-11',
                                       mine: true,
                                       post_id: blog.id},
                                o: [{id: obs1.id},
                                       {id: obs2.id}]
                               })
    assert bulk.save
    assert_not_nil obs1.reload.post
  end

end
