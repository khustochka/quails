# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :video, class: Video do
    sequence(:slug) {|n| "video_#{n}" }
    title { "Video of a bird" }
    youtube_id { "kdf83e7aks" }
    description { "This is a video" }
    observations { [FactoryBot.create(:observation)] }
    transient do
      asset_trait { :youtube_asset }
    end

    after(:create) do |video, evaluator|
      create(:external_asset, evaluator.asset_trait, media: video)
    end
  end
end
