# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    post_core
    title { "Test Post" }
    body { <<~TEXT }
      This is a post text.

      It must be multiline.
    TEXT
    status { "OPEN" }
    lang { "uk" }
  end
end
