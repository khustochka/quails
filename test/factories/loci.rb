# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :locus do |f|
  f.code "MyString"
  f.parent_id 1
  f.type "MyString"
  f.name_en "MyString"
  f.name_ru "MyString"
  f.name_uk "MyString"
  f.lat 1.5
  f.lon 1.5
end
