require 'tmp_cache'
require 'checklists_helper'

desc 'Tasks for importing species lists'
namespace :book do

  desc 'Fetch french names'
  task :get_french => :environment do

    include ChecklistsHelper

    regions = %w( ua usny )

    regions.each do |reg|
      puts "Fetching #{reg} checklist"
      list = TmpCache.fetch("list_fr_#{reg}.html", avibase_list_url(reg, 'clements', 'FR'))

      require 'nokogiri'

      doc = Nokogiri::HTML(list, nil, 'utf-8')

      doc.xpath('/html/body/table[2]/tr/td/table[2]/tr/td/table/tr').inject([]) do |list, row|
        if row.content !~ /(?:([A-Z]+FORMES): )?((?:[A-Z]+dae))\s*$/i
          begin
            sp_data = row.children
            if sp_data[1]
              #name_en = sp_data[0].content
              name_sci = sp_data[1].content
              name_fr = sp_data[2].content
              #puts "#{name_sci} => #{name_fr}"
              Species.find_by_name_sci(name_sci).update_attributes({name_fr: name_fr})
            end
          end
        end

      end
    end

  end

end