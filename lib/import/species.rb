require 'open-uri'
require 'app/helpers/species_helper'

module Import
  class SpeciesImport
    extend LegacyInit

    extend SpeciesHelper

    def self.parse_list(url)
      doc = Nokogiri::HTML(open(url), nil, 'utf-8')

      order = family = nil

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').inject([]) do |list, row|
        unless row.content.match(/([A-Z]+FORMES): ([A-Z]+dae)$/i).nil?
          order = $1.downcase.capitalize
          family = $2.downcase.capitalize
        else
          unless family.nil?
            sp_data = row.children
            name_sci = sp_data[1].content
            avb_id = sp_data[1].at('a')['href'].match(/^species\.jsp\?avibaseid=([\dA-F]+)$/)[1]
            name_en = sp_data[0].content
            list.push({
                    :name_sci => name_sci,
                    :name_en => name_en,
                    :order => order,
                    :family => family,
                    :avibase_id => avb_id
            })
          end
        end
        list
      end
    end

    def self.fill_db(hash)
      require 'app/models/species'
      hash.inject(1) do |index_num, sp|
        Species.create!(
                :name_sci => sp[:name_sci],
                :authority => '',
                :name_en => sp[:name_en],
                :name_ru => '',
                :name_uk => '',
                :order => sp[:order],
                :family => sp[:family],
                :index_num => index_num,
                :avibase_id => sp[:avibase_id]
        )
        index_num + 1
      end
    end

    def self.fetch_details
      require 'app/models/species'
      Species.where(:protonym => nil).each do |sp|
        puts "Fetching details for #{sp.index_num}: #{sp.name_sci}"

        avibase_id = sp[:avibase_id]

        doc_ru = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'RU')), nil, 'utf-8')
        doc_uk = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'UK')), nil, 'utf-8')

        begin
          data_ru = doc_ru.at("//td[@class='AVBHeader']").content.match(/^([^(]+) (\([^)]+\)) (\(?([^()]+)\)?)$/)

          name_ru = data_ru[1].strip

          protonym = doc_ru.at("//p[b[text()='Протоним:']]/i").content.strip

          authority = if sp.name_sci == data_ru[2].strip
            data_ru[3].strip
          else
            proto_parts = protonym.split(' ')
            sp.name_sci != "#{proto_parts.first} #{proto_parts.last}".downcase.capitalize ?
                    "(#{data_ru[4]})" :
                    "#{data_ru[4]}"
          end
          name_uk = doc_uk.at("//td[@class='AVBHeader']").content.match(/^(.+) \([A-Za-z ]+\) \(?([^()]+)\)?$/)[1].strip

          name_ru = '' if name_ru.downcase.eql?(sp.name_en.downcase)
          name_uk = '' if name_uk.downcase.eql?(sp.name_en.downcase)

          sp.update_attributes!({
                  :authority => authority,
                  :protonym => protonym,
                  :name_ru => name_ru,
                  :name_uk => name_uk
          })
        rescue
          puts "FAILED"
        end
      end
    end

    def self.create_mapping(file)
      require 'import/legacy/models/species'
      require 'app/models/species'

      init_legacy

      species_map = Legacy::Species.where("sp_id <> 'mulspp'").inject({}) do |memo, sp|
        unless newsp = (Species.find_by_name_sci(sp[:sp_la]) || Species.find_by_name_en(sp[:sp_en]))
          puts "\n\n\n#{sp[:sp_la]} not found"
          (gen, spnym) = sp[:sp_la].split(' ')
          puts "Possible matches:"
          matches = Species.where("name_sci LIKE '#{gen}%' OR name_sci LIKE '%#{spnym}'")
          (1..matches.size).each do |i|
            puts "#{i}) #{matches[i-1].name_sci}"
          end
          puts "Select option (0 to discard): "
          inpt = $stdin.gets
          newsp = inpt == 0 ? nil : matches[inpt.to_i-1]
        end
        newsp.update_attribute(:code, sp[:sp_id])
        memo.merge({sp[:sp_id] => {:id => newsp[:id], :name_sci => sp[:sp_la]}})
      end

      species_map.merge!('incogt' => {:id => nil})

      File.new(file, 'w').write(species_map.to_yaml)
    end

  end
end