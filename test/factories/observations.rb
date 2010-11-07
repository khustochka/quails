# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :observation do |f|
  f.species_id Species.find_by_code!('pasdom').id
  f.locus_id Locus.find_by_code!('brovary').id
  f.observ_date "2010-06-18"
  f.quantity "several"
  f.biotope "park"
  f.place "near the lake"
  f.notes "masc, fem"
  f.mine true
end
