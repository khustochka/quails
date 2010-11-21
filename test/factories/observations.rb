# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :observation do |f|
  f.species Species.find_by_code!('pasdom')
  f.locus Locus.find_by_code!('brovary')
  f.observ_date "2010-06-18"
  f.quantity "several"
  f.biotope "park"
  f.place "near the lake"
  f.notes "masc, fem"
  f.mine true
end
