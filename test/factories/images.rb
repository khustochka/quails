FactoryBot.define do
  factory :image, class: Image do
    sequence(:slug) { |n| "image_#{n}" }
    title "House Sparrow"
    description "This was taken somewhere"
    status 'PUBLIC'
    observations { [FactoryBot.create(:observation)] }
    assets_cache { ImageAssetsArray.new (
                                            [
                                                ImageAssetItem.new(:local, 800, 600, "#{slug}.jpg")
                                            ]
                                        ) }

    factory :image_on_flickr do
      flickr_id '123456'
      assets_cache { ImageAssetsArray.new (
                                              [
                                                  ImageAssetItem.new(:flickr, 800, 600, "http://localhost:3333/#{slug}.jpg")
                                              ]
                                          ) }
    end

  end
end
