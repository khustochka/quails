FactoryGirl.define do
  factory :post do |f|
    f.code "test-post"
    f.title "Test Post"
    f.text <<TEXT
This is a post text.

It must be multiline.
TEXT
    f.topic "OBSR"
    f.status "OPEN"
  end
end
