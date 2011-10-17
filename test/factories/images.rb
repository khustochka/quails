FactoryGirl.define do
  factory :image do
    code "house_sparrow"
    title "House Sparrow"
    description "This was taken somewhere"
    observations { [FactoryGirl.create(:observation)] }
  end
end