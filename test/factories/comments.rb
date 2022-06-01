# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    parent_comment { nil }
    name { "Commenter" }
    body { "Ahhaha!" }
    association :post
    approved { true }
  end
end
