# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :observation do |f|
  f.species_id 1
  f.locus_id 1
  f.observ_date "2010-06-18"
  f.quantity "MyString"
  f.biotope "MyString"
  f.place "MyString"
  f.notes "MyString"
  f.mine false
end
