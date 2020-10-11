# frozen_string_literal: true

FactoryBot.define do
  factory :observation do
    association :card
    taxon_id { Taxon.find_by_ebird_code("houspa").id }
    quantity { "several" }
    notes { "masc, fem" }
  end
end
