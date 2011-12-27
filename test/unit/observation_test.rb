require 'test_helper'

class ObservationTest < ActiveSupport::TestCase

  test 'do not destroy observation if having associated images' do
    observation = FactoryGirl.create(:observation)
    img = FactoryGirl.create(:image, code: 'picture-of-the-shrike', observations: [observation])
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      observation.destroy
    end
    assert observation.reload
    assert_equal [img], observation.images
  end

end