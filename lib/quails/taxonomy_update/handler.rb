# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Base for per-type manifest entry handlers; also the no-op handler for concept_change.
    #
    # Applier calls, for every `status: ok` entry:
    #   #prepare - after eBird taxa are imported, before taxa are re-synced
    #              (create taxa for new codes, move observations between taxa)
    #   #apply   - after taxa are re-synced (species records, splits, synonyms, images)
    #
    # Species records are linked explicitly here rather than through EBirdTaxon#promote,
    # whose lift_to_species attaches to any species with the same name.
    class Handler
      EXTRA_ATTRIBUTES = %w[authority name_en name_ru name_fr name_uk].freeze

      attr_reader :entry, :context

      def initialize(entry, context)
        @entry = entry
        @context = context
      end

      def prepare; end

      def apply; end

      private

      def log(message)
        context.log("  [#{entry["type"]} #{entry["code"] || entry["into"]}] #{message}")
      end

      def fail!(message)
        raise Applier::Error, "#{entry["type"]} #{entry["code"] || entry["into"]}: #{message}"
      end

      def taxon(code)
        Taxon.find_by(ebird_code: code) || fail!("no taxon #{code}")
      end

      def my_species(name_sci)
        Species.find_by(name_sci: name_sci) || fail!("no species #{name_sci}")
      end

      # A taxon for an eBird code, created without touching species. Order and parent
      # are set by the taxa re-sync that follows #prepare.
      def ensure_taxon(code)
        ebtx = EBirdTaxon.find_by(ebird_code: code, ebird_version: context.version) || fail!("#{code} is not in the new taxonomy")
        ebtx.taxon || Taxon.acts_as_list_no_update do
          tx = Taxon.create!(
            ebtx.attributes.slice("name_sci", "name_en", "ebird_code", "category", "order", "family", "taxon_concept_id")
              .merge(index_num: Taxon.maximum(:index_num).to_i + 1)
          )
          ebtx.update_column(:taxon_id, tx.id)
          log("created taxon #{code}")
          tx
        end
      end

      def move_observations(scope, to_code)
        target = ensure_taxon(to_code)
        count = scope.where.not(taxon_id: target.id).update_all(taxon_id: target.id)
        log("moved #{count} observations to #{to_code}") if count.positive?
      end

      # Makes +taxon+ (and its children) the species-rank taxa of +species+, detaching any others.
      def relink(species, taxon)
        keep = [taxon.id, *taxon.children.ids]
        Taxon.where(species_id: species.id).where.not(id: keep).find_each { |tx| tx.update!(species_id: nil) }
        taxon.attach_species(species)
      end

      def rename_species(species, name_sci, name_en: nil, reason: nil)
        if species.name_sci != name_sci
          old_name = species.name_sci
          if (other = Species.where.not(id: species.id).find_by(name_sci: name_sci))
            fail!("cannot rename #{old_name} to #{name_sci}: taken by species ##{other.id}")
          end
          species.update!(name_sci: name_sci, authority: nil, needs_review: true)
          add_synonym(old_name, species, reason)
          log("renamed #{old_name} to #{name_sci}")
        end
        species.update!(name_en: name_en) if name_en && species.name_en != name_en
      end

      # A split or lump changes the English name too, unless I chose my own.
      def survivor_name_en(species, taxon)
        taxon.name_en unless species.name_en_overwritten
      end

      def add_synonym(name_sci, species, reason)
        UrlSynonym.where(name_sci: species.name_sci).destroy_all
        UrlSynonym.find_or_initialize_by(name_sci: name_sci).update!(species: species, reason: reason)
      end

      def create_species(taxon)
        family = taxon.family&.[](/^\w+dae/) || fail!("no family for #{taxon.ebird_code}")
        UrlSynonym.where(name_sci: taxon.name_sci).destroy_all
        species = Species.acts_as_list_no_update do
          Species.create!(
            name_sci: taxon.name_sci, name_en: taxon.name_en, order: taxon.order, family: family,
            index_num: Species.maximum(:index_num).to_i + 1, needs_review: true
          )
        end
        log("created species #{species.name_sci}")
        species
      end

      # The image must come from the species' own observations; none if it has no images.
      def fix_image(species)
        species.reload
        first = species.images.first
        if first.nil?
          species.species_image&.destroy!
        elsif species.image.nil? || !species.images.exists?(species.image.id)
          species.update_image!
        end
      end

      def apply_extra(species, attrs)
        return if attrs.blank?

        unknown = attrs.keys - EXTRA_ATTRIBUTES
        fail!("unknown extra attributes: #{unknown.join(", ")}") if unknown.any?
        species.update!(attrs)
        species.update!(name_en_overwritten: true) if attrs.key?("name_en")
      end
    end
  end
end
