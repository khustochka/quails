# frozen_string_literal: true

# One-off: lumps the species I kept although eBird treats them as subspecies into their
# eBird species, using the eBird taxa already in the database. DRY_RUN=1 rolls back.
namespace :taxonomy do
  desc "Lump former overrides (Motacilla feldegg, Larus heuglini, Cygnus bewickii) into their eBird species."
  task lump_overrides: :environment do
    codes = %w[weywag6 lbbgul4 bewswa1]
    context = Struct.new(:version) do
      def log(message) = puts(message)
    end.new(EBirdTaxon.maximum(:ebird_version))

    ActiveRecord::Base.transaction do
      codes.each do |code|
        taxon = Taxon.find_by(ebird_code: code)
        ebtx = taxon&.ebird_taxon
        parent = ebtx&.parent&.taxon
        unless taxon&.category == "species" && parent&.species
          next puts("#{code}: skipped, not a species or no eBird parent species")
        end

        name_sci = taxon.name_sci
        taxon.update!(ebtx.attributes.slice("name_sci", "name_en", "category", "taxon_concept_id").merge(parent: parent))

        entry = { "type" => "lump", "into" => parent.ebird_code, "species" => [name_sci], "survivor" => parent.species.name_sci }
        Quails::TaxonomyUpdate::Handlers::Lump.new(entry, context).tap(&:prepare).apply
      end

      Observation.resync_species_ids!
      errors = Quails::TaxonomyUpdate::Verifier.new.errors
      abort errors.join("\n") if errors.any?
      if ENV["DRY_RUN"].present?
        puts "Dry run: rolled back."
        raise ActiveRecord::Rollback
      end
    end

    Rails.cache.clear unless ENV["DRY_RUN"].present?
  end
end
