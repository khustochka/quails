require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    assert_raise(ActiveRecord::DeleteRestrictionError) { @observation.destroy }
    assert @observation.reload
    assert_equal [img], @observation.images
  end

end
