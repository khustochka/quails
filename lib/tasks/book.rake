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
  task :load_to_db => :environment do

  end
end