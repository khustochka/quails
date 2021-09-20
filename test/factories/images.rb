# frozen_string_literal: true

FactoryBot.define do
  factory :image, class: Image do
    sequence(:slug) { |n| "image_#{n}" }
    title { "House Sparrow" }
    description { "This was taken somewhere" }
    status { "PUBLIC" }
    observations { [FactoryBot.create(:observation)] }
    stored_image { Rack::Test::UploadedFile.new("test/fixtures/files/tules.jpg", "image/jpeg") }

    factory :image_on_flickr do
      stored_image { }
      transient do
        asset_trait { :flickr_asset }
      end

      after(:create) do |img, evaluator|
        create(:external_asset, evaluator.asset_trait, media: img)
      end
    end

    factory :image_on_storage do
      # same as default
    end
  end
end
