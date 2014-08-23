FactoryGirl.define do
  factory :observation do
    association :card
    species_id { Species.find_by!(code: 'pasdom').id }
    quantity "several"
    place "near the lake"
    notes "masc, fem"
  end
end
