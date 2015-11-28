namespace :tax do

  desc "Creates species from taxa"
  task :create_species => :environment do

    Taxon.category_species.find_each.with_index do |tx, idx|
      sp = Species.create!(
                 name_sci: tx.name_sci,
                 name_en: tx.name_en,
                 order: tx.order,
                 family: tx.family,
                 index_num: idx + 1
      )
      Taxon.where("id = ? OR parent_id = ?", tx.id, tx.id).update_all(species_id: sp.id)
    end

  end

end
