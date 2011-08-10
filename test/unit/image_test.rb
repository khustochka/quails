require 'test_helper'

class ImageTest < ActiveSupport::TestCase

  should 'properly unlink observations when image destroyed' do
    observation = Factory.create(:observation)
    img = Factory.build(:image, :code => 'picture-of-the-shrike')
    img.observations << observation
    img.save
    assert_nothing_raised do
      img.destroy
    end
    assert observation.reload
    assert_equal 0, observation.images.size
  end

end
