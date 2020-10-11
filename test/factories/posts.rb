# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sequence(:slug) {|n| "post_#{n}" }
    title { "Test Post" }
    text { <<TEXT }
This is a post text.

It must be multiline.
TEXT
    topic { "OBSR" }
    status { "OPEN" }
  end
end
