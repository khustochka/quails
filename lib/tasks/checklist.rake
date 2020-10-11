# frozen_string_literal: true

require 'web_page_cache'
require 'legacy_checklists_helper'
require 'import/book_import'

REGION_TO_AVIBASE = {'ukraine' => 'ua', 'usa' => 'us'}

desc 'Tasks for checklists'
namespace :checklist do

  desc 'Import checklist'
  task :import => :environment do

    include LegacyChecklistsHelper

    if country = ENV['COUNTRY']

      reg = REGION_TO_AVIBASE[country]
      id = Locus.find_by(slug: country).id

      @cache = WebPageCache.new("tmp/")

      puts "Fetching #{country} checklist"
      source = @cache.fetch("list_#{reg}.html", avibase_list_url(reg, 'clements'), verbose: true)

      LocalSpecies.where(locus_id: id).delete_all

      BookImport.parse_list(source).each do |s|
        sp = Species.find_by(avibase_id: s[:avibase_id])

        #raise "#{s[:name_sci]} #{s[:avibase_id]} is nil" if sp.nil?
        if sp
          LocalSpecies.create(locus_id: id, species_id: sp.id, status: BookImport.convert_status(s[:status]))
        else
          puts "#{s[:name_sci]} #{s[:avibase_id]} is nil"
        end
      end

    else
      puts "Set COUNTRY env var, one of: #{REGION_TO_AVIBASE.keys.join(',')}"
    end

  end
end
