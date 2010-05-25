require 'nokogiri'
require 'active_support/concern'
require 'active_record/fixtures'

file = File.new('lib/import/input/clements_hol_ru.html', 'r')

doc = Nokogiri::HTML(file, nil, 'utf-8')

order = family = nil

list = []

doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').each do |row|
  unless row.content.match(/(\w+FORMES): (\w+dae)$/).nil?
    order = $1.downcase.capitalize
    family = $2
  else
    unless family.nil?
      sp_data = row.children
      sp_en = sp_data[0].content
      sp_la = sp_data[1].content
      sp_ru = sp_data[2].content
      status = sp_data[3].content
      list.push({
              :id => Fixtures.identify(sp_la),
              :name_sci => sp_la,
              :name_en => sp_en,
              :name_ru => sp_ru
      })
    end
  end
end

out = File.new('lib/import/output/clements.yaml', 'w')
out.write(list.to_yaml)