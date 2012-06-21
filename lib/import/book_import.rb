class BookImport
  def self.parse_list(io)

    require 'nokogiri'

    doc = Nokogiri::HTML(io, nil, 'utf-8')

    order = family = nil

    doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').inject([]) do |list, row|
      if row.content =~ /(?:([A-Z]+FORMES): )?((?:[A-Z]+dae))\s*$/i
        order, family = $1, $2
        order = order.nil? ? '' : order.strip.downcase.capitalize
        family = family.strip.downcase.capitalize
      else
        if family
          sp_data = row.children
          name_en = sp_data[0].content
          name_sci = sp_data[1].content
          avb_id = sp_data[1].at('a')['href'].match(/^species\.jsp\?avibaseid=([\dA-F]+)$/)[1]
          list.push({
                        name_sci: name_sci,
                        name_en: name_en,
                        order: order,
                        family: family,
                        avibase_id: avb_id
                    })
        end
      end
      list
    end

  end

  def fetch_details(sp)
    include SpeciesHelper

    cache = WebPageCache.new("tmp/")

    avibase_id = sp.avibase_id

    file_ru = cache.fetch("#{avibase_id}_RU.html", avibase_species_url(avibase_id, 'RU'), verbose: true)
    file_uk = cache.fetch("#{avibase_id}_UK.html", avibase_species_url(avibase_id, 'UK'), verbose: true)
    file_fr = cache.fetch("#{avibase_id}_FR.html", avibase_species_url(avibase_id, 'FR'), verbose: true)

    doc_ru = Nokogiri::HTML(file_ru, nil, 'utf-8')
    doc_uk = Nokogiri::HTML(file_uk, nil, 'utf-8')
    doc_fr = Nokogiri::HTML(file_fr, nil, 'utf-8')

    header_regex = /^([^(]+) (\([^)]+\)) (\(?([^()]+)\)?)$/

    data_fr = doc_fr.at("//td[@class='AVBHeader']").content.match(header_regex)

    name_fr = data_fr[1].strip

    protonym = doc_fr.at("//p[b[text()='Protonyme:']]/i").content.strip

    authority = if sp.name_sci == data_fr[2].strip
                  data_fr[3].strip
                else
                  proto_parts = protonym.split(' ')
                  sp.name_sci != "#{proto_parts.first} #{proto_parts.last}".downcase.capitalize ?
                      "(#{data_fr[4]})" :
                      "#{data_fr[4]}"
                end
    name_ru = doc_ru.at("//td[@class='AVBHeader']").content.match(header_regex)[1].strip
    name_uk = doc_uk.at("//td[@class='AVBHeader']").content.match(header_regex)[1].strip

    name_ru = '' if name_ru.downcase.eql?(sp.name_en.downcase)
    name_uk = '' if name_uk.downcase.eql?(sp.name_en.downcase)
    name_fr = '' if name_fr.downcase.eql?(sp.name_en.downcase)
    {
        protonym: protonym,
        authority: authority,
        name_ru: name_ru,
        name_uk: name_uk,
        name_fr: name_fr
    }
  end
end
