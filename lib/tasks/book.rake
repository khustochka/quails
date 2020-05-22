# encoding: utf-8

require 'web_page_cache'
require 'legacy_checklists_helper'
require 'import/book_import'

desc 'Tasks for importing species lists'
namespace :book do

  regions = %w( wpa NA1 )

  desc 'Fetch from web or html file, parse it and save to yaml'
  task :fetch => :environment do

    include LegacyChecklistsHelper

    @cache = WebPageCache.new("tmp/")

    puts 'Fetching Holarctic checklist'
    author = 'clements'
    source = @cache.fetch("holarctic_#{author}_real.html", avibase_list_url('hol', author), verbose: true)
    holarctic = BookImport.parse_list(source)

    desired = regions.map do |reg|
      puts "Fetching #{reg} checklist"
      source = @cache.fetch("list_#{reg}_#{author}_real.html", avibase_list_url(reg, author), verbose: true)
      BookImport.parse_list(source)
    end.inject(:+).uniq

    (holarctic & desired).each_with_index do |rec, i|
      Taxon.create!(rec.except(:status).merge(book_id: 3, authority: "", name_ru: "", name_uk: "", index_num: i+1))
    end

    #puts 'Missing:'
    #(desired - desired_ordered).each do |sp|
    #  unless desired_ordered.find { |ss| ss[:name_sci] == sp[:name_sci] } || Species.find_by(name_sci: sp[:name_sci])
    #    puts sp[:name_sci]
    #    ind = desired.index(sp)
    #    before = desired[ind - 1]
    #    after = desired[ind + 1]
    #    before_i = desired_ordered.index(before)
    #    after_i = desired_ordered.index(after)
    #    (before_i..after_i).each do |i|
    #      puts "#{i}. #{desired_ordered[i][:name_sci]}"
    #    end
    #    puts "Select to insert after: "
    #    val = $stdin.gets
    #
    #    desired_ordered.insert(val.strip.to_i + 1, sp)
    #
    #    puts "\n"
    #  end
    #end

    #puts 'Skipped missing:'
    #(desired - desired_ordered).each do |sp|
    #  puts sp[:name_sci]
    #end
    #
    #File.new("clements_#{regions.join('_')}.yml", 'w').write(desired_ordered.to_yaml)

  end

  desc 'Merge to DB'
  task :merge_to_db => :environment do
    records = File.open("clements_#{regions.join('_')}.yml") do |f|
      YAML.load(f.read)
    end
    records.each do |rec|
      sp = Species.find_by(name_sci: rec[:name_sci]) || Species.find_by(avibase_id: rec[:avibase_id])
      unless sp
        puts "No species '#{rec[:name_sci]}'"
        if nsp = Species.find_by(name_en: rec[:name_en])
          puts "  But there is '#{nsp.name_sci}' with the same name (#{nsp.name_en}). Code: #{nsp.code}"
        end
        _, nomen = rec[:name_sci].split(' ')
        if sps = Species.where("name_sci LIKE '%#{nomen}'")
          sps.each { |s| puts "  But there is '#{s.name_sci}' with different genus. Code: #{s.code}" }
        end

        gen, spn = rec[:name_sci].downcase.split(' ')
        new_code = gen[0, 3] + (gen != spn || gen.length < 6 ? spn[0, 3] : spn[-3, 3])
        puts "New code would be: #{new_code}"

        if confl_sp = Species.find_by(code: new_code)
          puts "  It is conflicting with #{confl_sp.name_sci}"
        end
        #puts "Enter the code to use (exisiting / new): "
        #code = $stdin.gets.strip || new_code
        code = new_code

        if sp = Species.find_by(code: code.strip)
          puts "  !! Will use #{sp.name_sci}"
        else
          puts "  !! Will create new species"
        end
        puts "\n"
      end

      if sp
        rec.merge!(
            {
                code: sp.code,
                id: sp.id
            }
        )
      else
        rec.merge!({code: code})
      end

    end

    final = Species.ordered_by_taxonomy.map{|sp| sp.attributes.slice('name_sci', 'id', 'code') }

    collected = []
    records.each_with_index do |rec, i|
      unless rec[:id]
        collected.push(rec)
        if records[i + 1][:id]
          puts "Inserting #{collected.map{|a| a[:name_sci]}.join(', ')} before #{records[i + 1][:name_sci]}"
          index_next = final.index { |el| el['name_sci'] == records[i + 1][:name_sci] }
          final.insert(index_next, *collected)
          collected = []
        end
        puts "\n"
      end
    end
    if collected.present?
      puts "Inserting #{collected.map{|a| a[:name_sci]}.join(', ')} after #{final[-1]['name_sci']}"
      final.insert(-1, *collected)
    end

    final.each_with_index do |sp, i|
      if sp['id']
        spc = Species.find_by(id: sp['id'])
      else
        spc = Species.new(sp)
      end
      spc.index_num = i + 1
      spc.save!
    end

    #File.new("clements_#{regions.join('_')}.yml", 'w').write(records.to_yaml)

  end

  desc 'Fetch details for species where they are missing'
  task :update_missing_details => :environment do

    include SpeciesHelper
    require 'nokogiri'

    Species.select {|s| s.authority.blank? }.each do |sp|
      puts "Fetching details for #{sp.name_sci}"
      sp.update!(BookImport.fetch_details(sp))
    end

  end

end
