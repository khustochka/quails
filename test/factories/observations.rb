FactoryBot.define do
  factory :observation do
    association :card
    taxon_id { Taxon.find_by_ebird_code("houspa").id }
    quantity "several"
    place "near the lake"
    notes "masc, fem"
  end
end
