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
end
