require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  test "do not save unless either flickr id or blob present" do

    img = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)])
    assert_not img.valid?
  end

end
