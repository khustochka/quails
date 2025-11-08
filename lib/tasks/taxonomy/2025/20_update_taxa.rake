# frozen_string_literal: true

namespace :tax do
  namespace :update2025 do
    task list_taxa_changes: :environment do
      taxa_sci = Taxon.joins(:ebird_taxon).includes(:ebird_taxon).where("taxa.name_sci != ebird_taxa.name_sci")

      puts "\n\nSCIENTIFIC NAME CHANGED:\n\n"

      taxa_sci.each do |tx|
        puts "#{tx.name_sci} (#{tx.category})"
        puts "               - changed to #{tx.ebird_taxon.name_sci} (#{tx.ebird_taxon.category})"
      end

      taxa_name = Taxon.joins(:ebird_taxon).includes(:ebird_taxon).where("taxa.name_en != ebird_taxa.name_en")

      puts "\n\nENGLISH NAME CHANGED:\n\n"

      taxa_name.each do |tx|
        puts "#{tx.name_sci} (#{tx.name_en})"
        puts "               - changed to #{tx.ebird_taxon.name_sci} (#{tx.ebird_taxon.name_en})"
      end
    end

    task update_taxa: :environment do
      exceptions = %w(weywag6 lbbgul4 bewswa1)

      codes = {}

      Taxon.acts_as_list_no_update do
        Taxon.joins(:ebird_taxon).preload(ebird_taxon: :parent).order("ebird_taxa.index_num").each_with_index do |taxon, idx|
          ebtx = taxon.ebird_taxon

          unless taxon.ebird_code.in?(exceptions)
            taxon.assign_attributes(
                name_sci: ebtx.name_sci,
                name_en: ebtx.name_en,
                category: ebtx.category,
                taxon_concept_id: ebtx.taxon_concept_id,
                parent_id: codes[ebtx.parent&.ebird_code]
            )
          end

          taxon.update!(
              order: ebtx.order,
              family: ebtx.family,
              index_num: idx + 1
          )

          codes[taxon.ebird_code] = taxon.id
        end

        Taxon.find_by_ebird_code("unrepbirdsp").update_column(:index_num, Taxon.count)
      end

      order_valid =
          Taxon.count("DISTINCT index_num") == Taxon.all.count &&
              Taxon.maximum(:index_num) == Taxon.all.count

      if order_valid
        puts "\nTaxa ordering validated."
      else
        raise "Taxa ordering invalid!"
      end
    end
  end
end
