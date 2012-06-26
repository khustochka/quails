require 'test_helper'

class ObservationTest < ActiveSupport::TestCase
  setup do
    @observation = create(:observation)
  end

  test "observation factory is valid" do

  end

  test 'do not destroy observation if having associated images' do
    img = create(:image, observations: [@observation])
    expect { @observation.destroy }.to raise_error(ActiveRecord::DeleteRestrictionError)
    assert @observation.reload
    assert_equal [img], @observation.images
  end

end
