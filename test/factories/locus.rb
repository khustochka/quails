FactoryGirl.define do
  factory :locus do
    sequence(:slug) {|n| "locus_#{(n+65).chr}" }
    parent_id nil
    sequence(:name_en) {|n| "Locus Anglais #{(n+65).chr}" }
    sequence(:name_ru) {|n| "Locus russe #{(n+65).chr}" }
    sequence(:name_uk) {|n| "Locus russe petite #{(n+65).chr}" }
    lat 0
    lon 0
  end
end
