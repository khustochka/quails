require 'test_helper'

class ImagesAssociationsTest < ActiveSupport::TestCase

  include ActionDispatch::TestProcess::FixtureFile

  test "do not save unless either flickr id or blob present" do
    img = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)])
    assert_not img.valid?
    assert_includes img.errors.full_messages, "should have image attached"
  end

  test "validate content type is image" do
    img = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)],
                    stored_image: fixture_file_upload(Rails.root.join('public', 'robots.txt')))
    assert_not img.valid?
    assert_includes img.errors.full_messages, "Stored image should have image content type"
  end

end
