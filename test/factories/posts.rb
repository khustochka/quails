FactoryGirl.define do
  factory :post do
    code "test-post"
    title "Test Post"
    text <<TEXT
This is a post text.

It must be multiline.
TEXT
    topic "OBSR"
    status "OPEN"
  end
end
