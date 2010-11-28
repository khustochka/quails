require 'test_helper'

class LocusTest < ActiveSupport::TestCase
#  should "be valid" do
#    assert Locus.new.valid?
#  end

  should 'not be saved with empty code' do
    loc          = Factory.build(:locus, :loc_type => 'Country')
    loc.code     = ''
    assert_raise(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  should 'not be saved with existing code' do
    loc          = Factory.build(:locus, :loc_type => 'Country')
    loc.code     = 'kiev'
    assert_raise(ActiveRecord::RecordInvalid) do
      loc.save!
    end
  end

  should 'properly find all subregions' do
    loc = Locus.find_by_code!('ukraine')
    actual = loc.get_subregions.map {|l| l.id}.sort
    expected = Locus.where(:code => ['ukraine', 'kiev_obl', 'khreson_obl', 'khreson', 'chernihiv']).map {|l| l.id}.sort
    not_expected = Locus.where(:code => ['usa', 'new_york', 'brooklyn', 'hoboken']).map {|l| l.id}.sort
    assert_equal [], expected - actual, 'Some expected values are not included'
    assert_equal [], not_expected & actual, 'Some unexpected values are included'
  end
end
