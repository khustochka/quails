FactoryGirl.define do
  factory :image do
    sequence(:code) {|n| "image_#{n}" }
    title "House Sparrow"
    description "This was taken somewhere"
    observations { [FactoryGirl.create(:observation)] }
  end
end