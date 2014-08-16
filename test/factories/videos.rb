# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video do
    sequence(:slug) {|n| "video_#{n}" }
    title "MyString"
    url "MyString"
    description "MyText"
    observations { [FactoryGirl.create(:observation)] }
  end
end
