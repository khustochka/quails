# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Checks taxa, species and observations after an update, or at any time.
    #
    #   errors   - invariants; Applier rolls back if any fail
    #   warnings - species whose names drifted from their eBird taxon
    #   review   - species marked needs_review, and texts that link to a split species
    #              (by name, code or synonym) whose observations went to another daughter
    class Verifier
      SPECIES_TAG = FormatStrategy::Base::SPECIES_CODES_REGEX
      MEDIA_OF_OWN_OBSERVATIONS = <<~SQL.squish
        SELECT 1 FROM media_observations mo JOIN observations o ON o.id = mo.observation_id
        WHERE mo.media_id = species_images.image_id AND o.species_id = species.id
      SQL

      def initialize(manifest: nil)
        @manifest = manifest
      end

      def errors
        problems = []
        [Taxon, Species].each do |model|
          count = model.count
          unless model.distinct.count(:index_num) == count && model.maximum(:index_num).to_i == count
            problems << "#{model.name} index_num is not 1..#{count}"
          end
        end
        orphans = Species.where.not(id: Taxon.category_species.where.not(species_id: nil).select(:species_id))
        problems << list("Species without a species-rank taxon", orphans.pluck(:name_sci))
        out_of_sync = Observation.joins(:taxon).where("observations.species_id IS DISTINCT FROM taxa.species_id").count
        problems << "#{out_of_sync} observations whose species differs from their taxon's" if out_of_sync.positive?
        versions = EBirdTaxon.distinct.pluck(:ebird_version).sort
        problems << "eBird taxa of several versions: #{versions.join(", ")}" if versions.size > 1
        foreign = Species.joins(:species_image).where.not("EXISTS (#{MEDIA_OF_OWN_OBSERVATIONS})")
        problems << list("Species images not from their own observations", foreign.pluck(:name_sci))
        imageless = Species.where.missing(:species_image).where(id: Observation.joins(:images).select(:species_id))
        problems << list("Species with photos but no image", imageless.pluck(:name_sci))
        problems.compact
      end

      def warnings
        drifted = Species.joins(:high_level_taxa).pluck(:name_sci, :name_en, :name_en_overwritten, "taxa.name_sci", "taxa.name_en")
        sci = drifted.filter_map { |name, _, _, tx_name, _| "#{name} (eBird: #{tx_name})" if name != tx_name }
        en = drifted.filter_map do |name, name_en, overwritten, _, tx_en|
          next if overwritten || name_en == tx_en || tx_en.sub(Differ::HYPHEN_ONLY, '\1\2 \3') == name_en

          "#{name}: #{name_en} (eBird: #{tx_en})"
        end
        [
          list("Scientific name differs from eBird", sci),
          list("English name differs from eBird (set name_en_overwritten to keep yours)", en),
        ].compact
      end

      def review
        [
          list("Species to review (needs_review)", Species.where(needs_review: true).order(:index_num).pluck(:name_sci)),
          list("Texts linking to a split species", split_mentions),
        ].compact
      end

      private

      def list(title, items)
        "#{title} (#{items.size}):\n    #{items.join("\n    ")}" if items.any?
      end

      # term => species name, for every way a text can link to a split species
      # that kept none or only some of its observations.
      def split_terms
        names = @manifest&.applicable&.filter_map do |e|
          next unless e["type"] == "split"

          rule = e["observations"] || {}
          targets = [rule["all"], *rule["by_locus"]&.values, rule["default"]].compact - ["leave"]
          e["species"] if (targets - [e["survivor"]]).any?
        end
        return {} if names.blank?

        ids = Species.where(name_sci: names).ids + UrlSynonym.where(name_sci: names).pluck(:species_id)
        Species.where(id: ids).preload(:url_synonyms).each_with_object({}) do |sp, terms|
          [sp.name_sci, sp.code, sp.legacy_code, *sp.url_synonyms.map(&:name_sci)].compact.each { |t| terms[t] = sp.name_sci }
        end
      end

      def split_mentions
        terms = split_terms
        return [] if terms.empty?

        texts = Post.joins(:post_core).where("body LIKE '%{{%'").pluck("post_cores.slug", :lang, :body)
          .map { |slug, lang, body| ["post #{slug} (#{lang})", body] } +
          Card.where("notes LIKE '%{{%'").pluck(:id, :notes).map { |id, notes| ["card #{id}", notes] } +
          Media.where("description LIKE '%{{%'").pluck(:slug, :description).map { |slug, text| ["media #{slug}", text] }

        texts.flat_map do |label, text|
          text.scan(SPECIES_TAG).filter_map do |word, term|
            name = terms[(term && term != "en" ? term : word).to_s.tr("_", " ")]
            "#{label}: #{name}" if name
          end.uniq
        end.sort
      end
    end
  end
end
