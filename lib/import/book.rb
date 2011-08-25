module Import
  module Book
    class Clements
      def self.parse(output_file)
        require 'nokogiri'

#        ukr_list = YAML.load_file('lib/import/output/ukraine.yaml').keys
#        usa_list = YAML.load_file('lib/import/output/usa.yaml').keys
#        species = (ukr_list + usa_list).uniq

        file = File.new('lib/import/input/clements_hol_ru.html', 'r')
        doc = Nokogiri::HTML(file, nil, 'utf-8')

        file_ua = File.new('lib/import/input/clements_ua_uk.html', 'r')
        doc_ua = Nokogiri::HTML(file_ua, nil, 'utf-8').xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table')

        order = family = nil
        list = []
        id = 0

        doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').each do |row|
          if  row.content =~ /([A-Z]+FORMES): ([A-Z]+dae)$/i
            order = $1.downcase.capitalize
            family = $2.downcase.capitalize
          else
            unless family.nil?
              sp_data = row.children
              sp_la = sp_data[1].content
              id += 1
              avb_id = sp_data[1].at('a')['href'].match(/^species\.jsp\?avibaseid=([\dA-F]+)$/)[1]
              sp_en = sp_data[0].content
              sp_ru = sp_data[2].content
              sp_uk = doc_ua.xpath("tr[td[a[i[text()='#{sp_la}']]]]").children[2].content rescue ''
              list.push({
                                :id => id,
                                :name_sci => sp_la,
                                :name_en => sp_en,
                                :name_ru => sp_ru,
                                :name_uk => sp_uk,
                                :avb_id => avb_id,
                                :order => order,
                                :family => family
                        })
            end
          end
        end

        File.new(output_file, 'w').write(list.to_yaml)
      end
    end
  end
end