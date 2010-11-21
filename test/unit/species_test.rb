require 'test_helper'

class SpeciesTest < ActiveSupport::TestCase
#  should "be valid" do
#    assert Species.new.valid?
#  end

  should 'be reordered alphabetically' do
    # TODO: Limited to 100 because of postgres strange ordering (LC_COLLATE must be set to "C")
    expected = Species.all.map {|sp| sp.name_sci }.sort[0..99]
    got = Species.limit(100).alphabetic.map {|sp| sp.name_sci }
    assert_equal expected, got
  end

  should 'order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got = Species.lifelist.map {|sp| sp.mind }
    expected = got.sort.reverse
    assert_equal expected, got
  end

end
