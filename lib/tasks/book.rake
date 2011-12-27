require 'tmp_cache'
require 'checklists_helper'
require 'import/book_import'

desc 'Tasks for importing species lists'
namespace :book do

  desc 'Fetch from web or html file, parse it and save to yaml'
  task :fetch_to_yaml do

    include ChecklistsHelper

    regions = %w( ua usny )

    puts 'Fetching Holarctic checklist'
    holarctic = BookImport.parse_list(TmpCache.fetch('holarctic.html', avibase_list_url('hol', 'clements')))

    desired = regions.map do |reg|
      puts "Fetching #{reg} checklist"
      BookImport.parse_list(TmpCache.fetch("list_#{reg}.html", avibase_list_url(reg, 'clements')))
    end.inject(&:+).uniq

    desired_ordered = holarctic & desired

    puts 'Missing:'
    (desired - desired_ordered).each do |sp|
      puts sp[:name_sci]
      ind = desired.index(sp)
      before = desired[ind - 1]
      after = desired[ind + 1]
      before_i = desired_ordered.index(before)
      after_i = desired_ordered.index(after)
      (before_i..after_i).each do |i|
        puts "#{i}. #{desired_ordered[i][:name_sci]}"
      end
      puts "Select to insert after: "
      val = $stdin.gets

      desired_ordered.insert(val.strip.to_i + 1, sp)

      puts "\n"
    end

    puts 'Recheck missing:'
    (desired - desired_ordered).each do |sp|
      puts sp[:name_sci]
    end

    File.new('clements_ua_ny.yml', 'w').write(desired_ordered.to_yaml)

  end

  desc 'Import checklist from yaml to the database'
  task load_to_db: :environment do
    f = File.open('vendor/clements_ua_ny.yml')
    records = YAML.load(f.read)
    newlist = records.map do |rec|
      sp = Species.find_by_name_sci(rec[:name_sci]) || Species.find_by_avibase_id(rec[:avibase_id])
      unless sp
        puts "No species '#{rec[:name_sci]}'"
        if nsp = Species.find_by_name_en(rec[:name_en])
          puts "  But there is '#{nsp.name_sci}' with the same name (#{nsp.name_en}). Code: #{nsp.code}"
        end
        _, nomen = rec[:name_sci].split(' ')
        if sps = Species.where("name_sci LIKE '%#{nomen}'")
          sps.each { |s| puts "  But there is '#{s.name_sci}' with different genus. Code: #{s.code}" }
        end
        puts "Enter the code to use (exisiting / new): "
        code = $stdin.gets
        if sp = Species.find_by_code(code.strip)
          puts "  !! Will use #{sp.name_sci}"
        else
          puts "  !! Will create new"
        end
      end

      if sp
        rec.merge(
            {
                code: sp.code,
                name_ru: sp.name_ru,
                name_uk: sp.name_uk,
                authority: sp.authority,
                protonym: sp.protonym
            }
        )
      else
        rec.merge({code: code})
      end
    end

    File.new('clements_ua_ny.yml', 'w').write(newlist.to_yaml)

  end
end