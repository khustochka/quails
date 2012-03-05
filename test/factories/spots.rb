FactoryGirl.define do
  factory :spot do
    association :observation
    lat 50.5
    lng 30.6
  end
end