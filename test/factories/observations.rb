FactoryGirl.define do
  factory :observation do
    species_id { Species.find_by_code!('pasdom').id }
    locus_id { Locus.find_by_code!('brovary').id }
    observ_date "2010-06-18"
    quantity "several"
    biotope "park"
    place "near the lake"
    notes "masc, fem"
    mine true
  end
end
