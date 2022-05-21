# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sequence(:slug) {|n| "post_#{n}" }
    title { "Test Post" }
    body { <<TEXT }
This is a post text.

It must be multiline.
TEXT
    topic { "OBSR" }
    status { "OPEN" }
    lang { "uk" }
  end
end
