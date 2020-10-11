# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :video, class: Video do
    sequence(:slug) {|n| "video_#{n}" }
    title { "MyString" }
    youtube_id { "kdf83e7aks" }
    description { "MyText" }
    observations { [FactoryBot.create(:observation)] }
    assets_cache { ImageAssetsArray.new (
                                            [
                                                ImageAssetItem.new(:youtube, 800, 600, "#{slug}.jpg")
                                            ]
                                        ) }
  end
end
