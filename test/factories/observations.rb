FactoryGirl.define do
  factory :observation do
    species { Species.find_by_code!('pasdom') }
    locus { Locus.find_by_code!('brovary') }
    observ_date "2010-06-18"
    quantity "several"
    biotope "park"
    place "near the lake"
    notes "masc, fem"
    mine true
  end
end
