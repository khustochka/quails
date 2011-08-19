require 'test_helper'

class ObservationTest < ActiveSupport::TestCase

  test 'not be destroyed if having associated images' do
    observation = Factory.create(:observation)
    img = Factory.build(:image, :code => 'picture-of-the-shrike')
    img.observations << observation
    img.save
    assert_raises(ActiveRecord::DeleteRestrictionError) do
      observation.destroy
    end
    assert observation.reload
    assert_equal [img], observation.images
  end

end