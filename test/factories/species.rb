# encoding: utf-8

# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define :species do |f|
  f.code 'eurhel'
  f.name_sci 'Eurypyga helias'
  f.authority 'Pallas, 1781'
  f.name_en 'Sunbittern'
  f.name_ru 'Солнечная цапля'
  f.name_uk ''
  f.index_num {Species.maximum(:index_num) + 1 rescue 1}
  f.order 'Gruiformes'
  f.family 'Eurypygidae'
  f.avibase_id '900C590B5EEE5157'
end
