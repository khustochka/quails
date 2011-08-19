require 'test_helper'

class LocusTest < ActiveSupport::TestCase

  test 'not be saved with empty code' do
    loc      = Factory.build(:locus, :loc_type => 'Country')
    loc.code = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  test 'not be saved with existing code' do
    loc      = Factory.build(:locus, :loc_type => 'Country')
    loc.code = 'kiev'
    assert_raises(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  test 'properly find all subregions' do
    loc          = Locus.find_by_code!('ukraine')
    actual       = loc.get_subregions.map(&:id).sort
    expected     = Locus.where(:code => ['ukraine', 'kiev_obl', 'kherson_obl', 'kherson', 'chernihiv']).map(&:id).sort
    not_expected = Locus.where(:code => ['usa', 'new_york', 'brooklyn', 'hoboken']).map(&:id).sort
    assert_equal [], expected - actual, 'Some expected values are not included'
    assert_equal [], not_expected & actual, 'Some unexpected values are included'
  end

  test 'not be destroyed if having child locations' do
    loc         = Locus.find_by_code!('ukraine')
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      loc.destroy
    end
    assert loc
  end

  test 'not be destroyed if having associated observations' do
    loc         = Locus.find_by_code!('kiev')
    observation = Factory.create(:observation, :locus => loc)
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      loc.destroy
    end
    assert observation.reload
    assert_equal loc, observation.locus
  end
end
