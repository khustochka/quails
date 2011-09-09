module Import
  class Checklist
    def self.parse(io, output_file)
      require 'nokogiri'

      doc = Nokogiri::HTML(io, nil, 'utf-8')

      full = YAML.load_file('lib/import/output/clements.yaml')

      list = {}

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr[td[not(@colspan)]]').each do |row|
        sp_data = row.children
        id = full.find do |f|
          f[:name_sci] == sp_data[1].content
        end
        if id.nil?
          puts "Failed to find #{sp_data[1].content}"
        else
          list[id[:id]] = sp_data[3].content.strip
        end
      end

      File.new(output_file, 'w').write(list.to_yaml)
    end
  end
end