FactoryGirl.define do
  factory :comment do
    association :post
  end
end