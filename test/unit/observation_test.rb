require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test "observation factory is valid" do

  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      @observation.destroy
    end
    assert @observation.reload
    assert_equal [img], @observation.images
  end

end
