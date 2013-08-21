FactoryGirl.define do
  factory :image do
    sequence(:slug) {|n| "image_#{n}" }
    title "House Sparrow"
    description "This was taken somewhere"
    status 'DEFLT'
    observations { [FactoryGirl.create(:observation)] }
    assets_cache { ImageAssetsArray.new (
          [
              ImageAssetItem.new(:local, 800, 600, "#{slug}.jpg")
          ]
                                        )}
  end
end
