require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test "observation factory is valid" do

  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [img], @observation.images
  end

  test 'search mine: false is different from mine: nil' do
    ob2 = create(:observation, mine: false)
    assert_equal Observation.search(mine: nil), Observation.search(mine: '')
    assert_equal [ob2], Observation.search(mine: false)
  end

end
