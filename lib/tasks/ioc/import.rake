require "csv"

namespace :ioc do

  desc "Import IOC taxa"
  task :import => :environment do
    version = -"10.2"
    current_species = nil
    idx = 0
    IocTaxon.acts_as_list_no_update do
      CSV.foreach('/Users/vitalii/IOC_Names_File_Plus-10.2_full_ssp.csv') do |row|
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
