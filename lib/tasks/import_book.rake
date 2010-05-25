require 'active_record/fixtures'

desc 'Importing data'
namespace :import do

  desc 'Import the authorities lists'
  namespace :book do

    desc "Importing Clements book"
    task :clements do
      ukr_list = YAML.load_file('lib/import/output/ukraine.yaml').keys
      usa_list = YAML.load_file('lib/import/output/usa.yaml').keys
      species = (ukr_list + usa_list).uniq

      file = File.new('lib/import/input/clements_hol_ru.html', 'r')
      doc = Nokogiri::HTML(file, nil, 'utf-8')

      file_ua = File.new('lib/import/input/clements_ua_uk.html', 'r')
      doc_ua = Nokogiri::HTML(file_ua, nil, 'utf-8').xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table')

      order = family = nil
      list = []

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').each do |row|
        unless row.content.match(/(\w+FORMES): (\w+dae)$/).nil?
          order = $1.downcase.capitalize
          family = $2
        else
          unless family.nil?
            sp_data = row.children
            sp_la = sp_data[1].content
            id = Fixtures.identify(sp_la)
            if species.include?(id)
              avb_id = sp_data[1].xpath('a')[0]['href'].match(/^species\.jsp\?avibaseid=([\dA-F]+)$/)[1]
              sp_en = sp_data[0].content
              sp_ru = sp_data[2].content
              sp_uk = ukr_list.include?(id) ?
                      doc_ua.xpath("tr[td[a[i[text()='#{sp_la}']]]]").children[2].content :
                      nil
              list.push({
                      :id => id,
                      :name_sci => sp_la,
                      :name_en => sp_en,
                      :name_ru => sp_ru,
                      :name_uk => sp_uk,
                      :avb_id => avb_id
              })
            end
          end
        end
      end

      out = File.new('lib/import/output/clements.yaml', 'w')
      out.write(list.to_yaml)
    end

  end

end
