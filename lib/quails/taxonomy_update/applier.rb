# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Applies a new eBird taxonomy and a reviewed Manifest in one transaction, in a fixed order:
    #
    #   1. import eBird taxa (upsert by code, new version and order)
    #   2. handlers#prepare
    #   3. re-sync taxa from their eBird taxa (overrides keep names, rank and parent)
    #   4. handlers#apply, then taxa without a species inherit their parent's
    #   5. remove taxa and eBird taxa that left the taxonomy
    #   6. re-order species
    #   7. resync observations.species_id
    #   8. check invariants
    #
    # A dry run, or any failure, rolls everything back.
    class Applier
      class Error < StandardError; end

      HANDLERS = {
        "concept_change" => Handler,
        "rename" => Handlers::Rename,
        "code_change" => Handlers::CodeChange,
        "split" => Handlers::Split,
        "lump" => Handlers::Lump,
      }.freeze

      attr_reader :source, :version

      def initialize(source:, manifest:, version:, overrides: [], dry_run: false, io: $stdout)
        @source = source
        @manifest = manifest
        @version = Integer(version)
        @overrides = overrides.to_set
        @dry_run = dry_run
        @io = io
      end

      def run
        errors = @manifest.errors(HANDLERS.keys)
        raise Error, "Manifest cannot be applied:\n  #{errors.join("\n  ")}" if errors.any?

        before = stats
        handlers = @manifest.applicable.map { |entry| HANDLERS.fetch(entry["type"]).new(entry, self) }

        ActiveRecord::Base.transaction(requires_new: true) do
          step("Importing eBird taxa") { import_ebird_taxa }
          step("Preparing #{handlers.size} entries") { handlers.each(&:prepare) }
          step("Re-syncing taxa") { sync_taxa }
          step("Applying entries") { handlers.each(&:apply) }
          step("Linking new subspecies") { inherit_species }
          step("Removing obsolete taxa") { remove_obsolete }
          step("Re-ordering species") { order_species }
          step("Resyncing observation species") { Observation.resync_species_ids! }
          step("Checking") { check! }
          report(before, stats)
          raise ActiveRecord::Rollback if @dry_run
        end

        log(@dry_run ? "\nDry run: rolled back." : "\nApplied.")
        Rails.cache.clear unless @dry_run
      end

      def log(message)
        @io.puts(message)
      end

      private

      def step(title)
        log("== #{title}")
        yield
      end

      def import_ebird_taxa
        existing = EBirdTaxon.all.index_by(&:ebird_code)
        EBirdTaxon.acts_as_list_no_update do
          source.rows.each_with_index do |row, idx|
            et = existing[row.code] || EBirdTaxon.new(ebird_code: row.code)
            et.assign_attributes(
              name_sci: row.name_sci, name_en: row.name_en, category: row.category,
              order: row.order, family: row.family, taxon_concept_id: row.concept && "avibase-#{row.concept}",
              ebird_order_num_str: row.taxon_order, ebird_version: version, index_num: idx + 1
            )
            et.save! if et.changed?
          end

          ids = EBirdTaxon.where(ebird_version: version).pluck(:ebird_code, :id).to_h
          EBirdTaxon.where(ebird_version: version).find_each do |et|
            parent_id = ids[source[et.ebird_code].parent_code]
            et.update_column(:parent_id, parent_id) if et.parent_id != parent_id
          end
        end
      end

      def sync_taxa
        ids = Taxon.pluck(:ebird_code, :id).to_h
        Taxon.acts_as_list_no_update do
          current = Taxon.joins(:ebird_taxon).merge(EBirdTaxon.where(ebird_version: version))
            .preload(ebird_taxon: :parent).order("ebird_taxa.index_num")
          current.each_with_index do |taxon, idx|
            ebtx = taxon.ebird_taxon
            unless taxon.ebird_code.in?(@overrides)
              taxon.assign_attributes(
                name_sci: ebtx.name_sci, name_en: ebtx.name_en, category: ebtx.category,
                taxon_concept_id: ebtx.taxon_concept_id, parent_id: ids[ebtx.parent&.ebird_code]
              )
            end
            taxon.assign_attributes(order: ebtx.order, family: ebtx.family, index_num: idx + 1)
            taxon.save! if taxon.changed?
          end
        end
      end

      def inherit_species
        Taxon.connection.update(<<~SQL.squish)
          UPDATE taxa SET species_id = parents.species_id FROM taxa parents
          WHERE taxa.parent_id = parents.id AND taxa.species_id IS NULL AND parents.species_id IS NOT NULL
        SQL
      end

      # Taxa whose code left eBird must have been re-homed by a handler unless they are unused.
      def remove_obsolete
        obsolete = Taxon.joins(:ebird_taxon).merge(EBirdTaxon.where.not(ebird_version: version))
        blocked = obsolete.select { |tx| tx.observations.exists? || tx.species&.high_level_taxon == tx }
        if blocked.any?
          raise Error, "Taxa removed from eBird still in use (add manifest entries): #{blocked.map(&:ebird_code).join(", ")}"
        end

        obsolete.each do |tx|
          tx.children.update_all(parent_id: nil)
          tx.ebird_taxon.update_column(:taxon_id, nil)
          tx.delete
        end
        EBirdTaxon.where.not(ebird_version: version).delete_all

        # Local taxa (no eBird counterpart, e.g. unrepbirdsp) go after all eBird taxa.
        Taxon.acts_as_list_no_update do
          offset = Taxon.joins(:ebird_taxon).count
          Taxon.where.missing(:ebird_taxon).order(:index_num).each_with_index do |tx, idx|
            tx.update_column(:index_num, offset + idx + 1)
          end
        end
      end

      def order_species
        Species.acts_as_list_no_update do
          Species.joins(:high_level_taxa).preload(:high_level_taxa).order("taxa.index_num").each_with_index do |species, idx|
            tx = species.high_level_taxon
            species.assign_attributes(
              order: tx.order || species.order,
              family: tx.family&.[](/^\w+dae/) || species.family,
              index_num: idx + 1
            )
            species.save! if species.changed?
          end
        end
      end

      def check!
        problems = []
        [Taxon, Species].each do |model|
          count = model.count
          unless model.distinct.count(:index_num) == count && model.maximum(:index_num) == count
            problems << "#{model.name} index_num is not 1..#{count}"
          end
        end
        orphans = Species.where.not(id: Taxon.category_species.where.not(species_id: nil).select(:species_id)).pluck(:name_sci)
        problems << "Species without a species-rank taxon: #{orphans.join(", ")}" if orphans.any?
        raise Error, problems.join("\n") if problems.any?
      end

      def stats
        {
          "eBird taxa" => EBirdTaxon.count,
          "Taxa" => Taxon.count,
          "Species" => Species.count,
          "Observed species" => Observation.identified.count_distinct_species,
        }
      end

      def report(before, after)
        log("\n#{"".ljust(18)}#{"before".rjust(8)}#{"after".rjust(8)}")
        before.each_key { |k| log("#{k.ljust(18)}#{before[k].to_s.rjust(8)}#{after[k].to_s.rjust(8)}") }
      end
    end
  end
end
