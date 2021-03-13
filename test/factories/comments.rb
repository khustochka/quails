# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    parent_id { nil }
    name { "Commenter" }
    body { "Ahhaha!" }
    association :post
    approved { true }
  end
end
