FactoryGirl.define do
  factory :comment do
    parent_id 0
    name 'Commenter'
    text 'Ahhaha!'
    association :post
    approved true
  end
end
