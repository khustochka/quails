FactoryBot.define do
  factory :card do
    locus_id { Locus.find_by!(slug: 'brovary').id }
    observ_date { "2010-06-18" }
    resolved { true }
  end
end
