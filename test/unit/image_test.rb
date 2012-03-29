require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  setup do
    @image = create(:image)
  end

  test "image factory is valid" do
    create(:image)
  end
end
