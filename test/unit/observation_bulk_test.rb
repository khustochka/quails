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
    expect(bulk.errors).to be_blank
  end

  test 'observation bulk save returns error if no observations provided' do
    bulk = ObservationBulk.new({c: {locus_id: seed(:brovary).id,
                                       observ_date: '2010-05-05', mine: true}
                               })
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    expect(bulk.errors).not_to be_blank
  end

  test 'Observations bulk save combines errors for incorrect common parameters and zero observations' do
    bulk = ObservationBulk.new({c: {locus_id: '', observ_date: '', mine: true}})
    assert_difference('Observation.count', 0) do
      bulk.save
    end
    err = bulk.errors
    expect(err["observ_date"]).to eq(["can't be blank"])
    expect(err["locus_id"]).to eq(["can't be blank"])
    expect(err["base"]).to eq(["provide at least one observation"])
  end

  test 'Observations bulk save does not save the bunch if any observation is wrong' do
    bulk = ObservationBulk.new({c: {locus_id: seed(:brovary).id,
                                       observ_date: '2010-05-05', mine: true},
                                o: [{species_id: ''}, {species_id: 2}]
                               })
    assert_difference('Observation.count', 0) do
      expect(bulk.save).to be_false
    end
    expect(bulk.errors).not_to be_blank
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
      expect(bulk.save).to be_true
    end
    expect(obs1.reload.species.code).to eq('cornix')
    expect(obs2.reload.notes).to eq('Voices')
  end

  test 'Observations bulk save both saves new and updates existing' do
    obs1 = create(:observation, species: seed(:cormon))
    bulk = ObservationBulk.new({c: {locus_id: seed(:kiev).id,
                                       observ_date: '2010-11-11', mine: true},
                                o: [{species_id: seed(:cornix).id, biotope: 'city'},
                                       {id: obs1.id, notes: 'Voices', biotope: 'city'}]
                               })
    assert_difference('Observation.count', 1) do
      expect(bulk.save).to be_true
    end
    expect(bulk[0].species.code).to eq('cornix')
    expect(bulk[1].notes).to eq('Voices')
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
    expect(bulk.save).to be_false
    expect(obs1.reload.post).to be_nil
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
    expect(bulk.save).to be_true
    expect(obs1.reload.post).not_to be_nil
  end

end
