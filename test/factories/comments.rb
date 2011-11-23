FactoryGirl.define do
  factory :comment do
    name 'Commenter'
    text 'Ahhaha!'
    association :post
  end
end