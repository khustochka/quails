# frozen_string_literal: true

FactoryBot.define do
  factory :post_core do
    sequence(:slug) { |n| "post-#{n}" }
    topic { "OBSR" }
  end
end
