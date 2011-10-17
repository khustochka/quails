# encoding: utf-8

FactoryGirl.define do
  factory :species do
    code 'eurhel'
    name_sci 'Eurypyga helias'
    authority 'Pallas, 1781'
    name_en 'Sunbittern'
    name_ru 'Солнечная цапля'
    name_uk ''
    index_num { Species.maximum(:index_num) + 1 rescue 1 }
    order 'Gruiformes'
    family 'Eurypygidae'
    avibase_id '900C590B5EEE5157'
  end
end
