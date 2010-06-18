require 'open-uri'

module Import
  class SpeciesImport

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

    def self.fetch_details(hash)
      require 'app/models/species'
      hash.each do |sp|
        avibase_id = sp[:avibase_id]

        doc_ru = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'RU')), nil, 'utf-8')
        doc_uk = Nokogiri::HTML(open(avibase_species_url(avibase_id, 'UK')), nil, 'utf-8')

        # TODO: fetch the name_ru, name_uk, authority from the pages

        name_ru = '' if name_ru == sp[:name_en]
        name_uk = '' if name_uk == sp[:name_en]

        Species.first(:avibase_id => avibase_id).update!({
                :authority => authority,
                :name_ru => name_ru,
                :name_uk => name_uk
        })
      end
    end

  end
end