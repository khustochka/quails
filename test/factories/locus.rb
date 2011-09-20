FactoryGirl.define do
  factory :locus do |f|
    f.code 'loccode'
    f.parent_id nil
    f.loc_type 'Country'
    f.name_en "Locus Anglais"
    f.name_ru "Locus russe"
    f.name_uk "Locus russe petite"
    f.lat 0
    f.lon 0
  end
end
