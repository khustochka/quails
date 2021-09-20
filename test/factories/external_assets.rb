# frozen_string_literal: true
#
FactoryBot.define do
  factory :external_asset, class: ExternalAsset do
    trait :youtube_asset do
      service_name { "youtube" }
      sequence(:external_key) { |n| "kdf83e7aks-#{n}" }
    end

    trait :flickr_asset do
      service_name { "flickr" }
      sequence(:external_key) { |n| "12345678#{n}" }
    end
  end
end
