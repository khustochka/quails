# frozen_string_literal: true

FactoryBot.define do
  factory :observation do
    transient do
      post { nil }
    end

    card
    taxon_id { Taxon.find_by(ebird_code: "houspa").id }
    quantity { "several" }
    notes { "masc, fem" }

    post_core { post&.post_core }
  end
end
