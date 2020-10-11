# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :ebird_file, :class => 'Ebird::File' do
    name { "MyString" }
    status { "NEW" }
  end
end
