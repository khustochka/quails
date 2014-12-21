# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video, class: Video do
    sequence(:slug) {|n| "video_#{n}" }
    title "MyString"
    youtube_id "kdf83e7aks"
    description "MyText"
    observations { [FactoryGirl.create(:observation)] }
  end
end
