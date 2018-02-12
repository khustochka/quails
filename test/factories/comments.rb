FactoryBot.define do
  factory :comment do
    parent_id nil
    name 'Commenter'
    text 'Ahhaha!'
    association :post
    approved true
  end
end
