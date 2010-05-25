require 'active_record/fixtures'

desc 'Importing data'
namespace :import do
  
  desc 'Import the checklists from avibase files to yaml'
  namespace :checklist do

    desc "Importing Ukraine's checklist"
    task :ukraine do
      puts "Importing Ukraine's checklist"

      file = File.new('lib/import/input/clements_ua_ru.html', 'r')

      doc = Nokogiri::HTML(file, nil, 'utf-8')

      order = family = nil

      list = {}

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr[td[not(@colspan)]]').each do |row|
        sp_data = row.children
        list[Fixtures.identify(sp_data[1].content)] = sp_data[3].content.strip
      end

      out = File.new('lib/import/output/ukraine.yaml', 'w')
      out.write(list.to_yaml)
    end

    desc "Importing USA checklist"
    task :usa do
      puts "Importing USA checklist"

      file = File.new('lib/import/input/clements_us_ru.html', 'r')

      doc = Nokogiri::HTML(file, nil, 'utf-8')

      order = family = nil

      list = {}

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr[td[not(@colspan)]]').each do |row|
        sp_data = row.children
        list[Fixtures.identify(sp_data[1].content)] = sp_data[3].content.strip
      end

      out = File.new('lib/import/output/usa.yaml', 'w')
      out.write(list.to_yaml)
    end
  end
end