# frozen_string_literal: true

require "test_helper"

class ImagesAssociationsTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "do not save unless either flickr id or blob present" do
    img = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)])
    assert_not img.valid?
    assert_includes img.errors.full_messages, "should have image attached"
  end

  test "validate content type is image" do
    img = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)],
      stored_image: fixture_file_upload(Rails.root.join("public/robots.txt")))
    assert_not img.valid?
    assert_includes img.errors.full_messages, "Stored image should have image content type"
  end

  test "validate blob uniqueness among images" do
    img1 = Image.create(slug: "testimg1", observations: [FactoryBot.create(:observation)],
      stored_image: fixture_file_upload("tules.jpg"))

    img2 = Image.new(slug: "testimg", observations: [FactoryBot.create(:observation)],
      stored_image: img1.stored_image.blob.signed_id)
    assert_not img2.valid?
    assert_includes img2.errors.full_messages, "Stored image blob already in use by another image"
  end
end
