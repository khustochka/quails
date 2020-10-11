# frozen_string_literal: true

FactoryBot.define do
  factory :taxon do
    name_sci { "Crex crex" }
    name_en { "Corn Crake" }
    category { "species" }
    ebird_code { "corcra" }
    sequence(:index_num)
  end
end
