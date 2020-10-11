# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :page do
    title { "MyString" }
    text { "MyText" }
    public { true }
  end
end
