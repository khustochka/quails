FactoryGirl.define do
  factory :image, class: Image do
    sequence(:slug) { |n| "image_#{n}" }
    title "House Sparrow"
    description "This was taken somewhere"
    status 'DEFLT'
    observations { [FactoryGirl.create(:observation)] }
    assets_cache { ImageAssetsArray.new (
                                            [
                                                ImageAssetItem.new(:local, 800, 600, "#{slug}.jpg")
                                            ]
                                        ) }

    factory :image_on_flickr do
      flickr_id '123456'
    end

  end
end
