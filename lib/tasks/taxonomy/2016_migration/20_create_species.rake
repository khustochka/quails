# frozen_string_literal: true

namespace :tax do

  desc "Creates species from taxa"
  task :create_species => :environment do

    puts "\n********** Create species from taxa"

    Species.delete_all
    Taxon.category_species.find_each.with_index do |tx, idx|
      begin
      sp = Species.create!(
                 name_sci: tx.name_sci,
                 name_en: tx.name_en,
                 order: tx.order,
                 family: tx.family.match(/^\w+dae/)[0],
                 index_num: idx + 1
      )
      Taxon.where("id = ? OR parent_id = ?", tx.id, tx.id).update_all(species_id: sp.id)
      rescue => e
        puts tx.inspect
        raise e
      end
    end

  end

end
