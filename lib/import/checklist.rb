require 'active_record/fixtures'

module Import
  class Checklist
    def self.parse(output_file)
      doc = Nokogiri::HTML(io, nil, 'utf-8')

      list = {}

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr[td[not(@colspan)]]').each do |row|
        sp_data = row.children
        list[Fixtures.identify(sp_data[1].content)] = sp_data[3].content.strip
      end

      File.new(output_file, 'w').write(list.to_yaml)
    end
  end
end