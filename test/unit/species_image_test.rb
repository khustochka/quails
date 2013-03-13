require 'test_helper'

class SpeciesImageTest < ActiveSupport::TestCase

  test 'first species image should be attached to it automatically' do
    img = create(:image)
    assert_equal [img.id], img.species.map(&:image_id)
  end

  test 'adding another species image should not overwrite existing one' do
    img = create(:image)
    img2 = create(:image)
    assert_equal [img.id], img.species.map(&:image_id)
  end

end
