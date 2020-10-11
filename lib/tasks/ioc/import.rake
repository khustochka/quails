# frozen_string_literal: true

require "csv"

namespace :ioc do

  desc "Import IOC taxa"
  task :import => :environment do
    version = -"10.2"
    current_species = nil
    idx = 0
    ioc_file = ENV["IOC_NAMES_CSV"]
    raise "Set env var IOC_NAMES_CSV to the file path." unless ioc_file
    IocTaxon.acts_as_list_no_update do
      CSV.foreach(ioc_file) do |row|
        rank = row[1]
        next unless rank.in?(%w(Species ssp))
        idx += 1
        current_species = nil if rank == -"Species"
        taxon = IocTaxon.create!(
            rank: rank,
            extinct: row[2] == -"†",
            name_en: row[3].presence,
            name_sci: row[5].presence,
            authority: row[6],
            breeding_range: row[7],
            index_num: idx,
            ioc_species: current_species,
            version: version
        )
        current_species = taxon if rank == -"Species"
      end
    end
  end

end
