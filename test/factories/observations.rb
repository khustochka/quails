FactoryGirl.define do
  factory :observation do
    species_id { Species.find_by_code!('pasdom').id }
    locus_id { Locus.find_by_slug!('brovary').id }
    observ_date "2010-06-18"
    quantity "several"
    place "near the lake"
    notes "masc, fem"
    mine true
  end
end
