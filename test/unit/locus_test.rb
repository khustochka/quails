require 'test_helper'

class LocusTest < ActiveSupport::TestCase

  test 'do not save locus with empty code' do
    loc      = FactoryGirl.build(:locus, :loc_type => 'Country')
    loc.code = ''
    assert_raises(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  test 'do not save locus with existing code' do
    loc      = FactoryGirl.build(:locus, :loc_type => 'Country')
    loc.code = 'kiev'
    assert_raises(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  test 'properly find all locus subregions' do
    loc          = Locus.find_by_code!('ukraine')
    actual       = loc.get_subregions.map(&:id).sort
    expected     = Locus.where(:code => ['ukraine', 'kiev_obl', 'kherson_obl', 'kherson', 'chernihiv']).map(&:id).sort
    not_expected = Locus.where(:code => ['usa', 'new_york', 'brooklyn', 'hoboken']).map(&:id).sort
    assert_equal [], expected - actual, 'Some expected values are not included'
    assert_equal [], not_expected & actual, 'Some unexpected values are included'
  end

  test 'do not destroy locus if it has child locations' do
    loc         = Locus.find_by_code!('ukraine')
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      loc.destroy
    end
    assert loc
  end

  test 'do not destroy locus if it has associated observations' do
    loc         = Locus.find_by_code!('kiev')
    observation = FactoryGirl.create(:observation, :locus => loc)
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      loc.destroy
    end
    assert observation.reload
    assert_equal loc, observation.locus
  end
end
