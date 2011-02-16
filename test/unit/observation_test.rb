require 'test_helper'

class ObservationTest < ActiveSupport::TestCase

  should 'order lifelist correctly' do
    Factory.create(:observation, :species => Species.find_by_code!('pasdom'), :observ_date => "2010-06-20")
    Factory.create(:observation, :species => Species.find_by_code!('melgal'), :observ_date => "2010-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anapla'), :observ_date => "2009-06-18")
    Factory.create(:observation, :species => Species.find_by_code!('anacly'), :observ_date => "2007-07-18")
    Factory.create(:observation, :species => Species.find_by_code!('embcit'), :observ_date => "2009-08-09")
    got      = Observation.lifelist.map { |ob| ob.observ_date }
    expected = got.sort.reverse
    assert_equal expected, got
  end

end
