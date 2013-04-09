FactoryGirl.define do
  factory :card do
    locus_id { Locus.find_by_slug!('brovary').id }
    observ_date "2010-06-18"
    with_me true
  end
end
