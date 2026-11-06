# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Compares a new eBird taxonomy (Source) with the current ebird_taxa / taxa / species
    # and drafts one manifest entry per affected species, plus entries for removed taxa
    # that still have observations. Every entry starts as `status: draft` for manual review.
    #
    # Entry types:
    #   split          - species became a slash/spuh, vanished, or kept its code with a new
    #                    concept while subspecies became species or a new slash pairs it
    #                    with a new species
    #   lump           - species became a subspecies/form of another species
    #   code_change    - code removed, same concept under another code
    #   concept_change - same code, new concept, no daughters found (usually nothing to do)
    #   rename         - scientific and/or English name changed
    #   ambiguous      - removed with no concept or daughter match
    class Differ
      HYPHEN_ONLY = /\A(.*)([^ ]+)-([^ ]+)\Z/

      def initialize(source)
        @source = source
      end

      def entries
        @entries ||= (species_entries + lump_entries + removed_taxa_entries).sort_by { |e| e.delete(:_index) }
      end

      # Codes of my eBird-based taxa without observations that disappear from the new taxonomy.
      def removed_unused
        my_taxa.reject { |tx| @source[tx.ebird_code] || observation_counts[tx.id] || !ebird_taxa[tx.ebird_code] }
          .map(&:ebird_code)
      end

      def to_h
        { "entries" => entries.map(&:deep_stringify_keys), "removed_unused" => removed_unused }
      end

      private

      def species_entries
        @lumps = Hash.new { |h, k| h[k] = [] }
        Species.includes(:high_level_taxa).order(:index_num).filter_map do |species|
          taxon = species.high_level_taxon
          next unless taxon

          classify(species, taxon)
        end
      end

      def classify(species, taxon)
        old = ebird_taxa[taxon.ebird_code]
        new = @source[taxon.ebird_code]
        # Local-only taxa, and species kept above eBird's rank (overrides), are not eBird changes.
        return if old.nil? || old.category != "species"

        if new.nil?
          removed_species_entry(species, taxon, old)
        elsif !new.species?
          if new.category.in?(%w[slash spuh])
            split_entry(species, taxon, old)
          else
            @lumps[@source.species_for(new.code)&.code] << [species, taxon]
            nil
          end
        elsif concept_changed?(old, new)
          daughters = daughters_for(old)
          if daughters.size > 1
            split_entry(species, taxon, old, daughters)
          else
            base_entry("concept_change", species, taxon)
          end
        else
          rename_entry(species, taxon, old, new)
        end
      end

      def removed_species_entry(species, taxon, old)
        same_concept = old&.taxon_concept_id ? @source.with_concept(old.taxon_concept_id) : []
        if same_concept.size == 1
          target = same_concept.first
          entry = base_entry("code_change", species, taxon).merge(new_code: target.code, matched_by: "concept")
          return entry.merge(renames(species, old, target))
        end

        daughters = daughters_for(old)
        return split_entry(species, taxon, old, daughters) if daughters.any?

        base_entry("ambiguous", species, taxon).merge(candidates: same_concept.map(&:code))
      end

      def split_entry(species, taxon, old, daughters = daughters_for(old))
        survivor = daughters.find { |d| d[:name_sci] == species.name_sci } ||
          daughters.find { |d| d[:code] == taxon.ebird_code }
        base_entry("split", species, taxon).merge(
          daughters: daughters,
          survivor: survivor&.dig(:code),
          observations: {},
          local_species: {}
        )
      end

      def lump_entries
        species_entries if @lumps.nil?
        @lumps.map do |target_code, members|
          target = @source[target_code]
          species_list = members.map(&:first)
          first_species, first_taxon = members.min_by { |_, tx| tx.index_num }
          survivor = Taxon.find_by(ebird_code: target_code, category: "species")&.species ||
            species_list.find { |sp| sp.name_sci == target&.name_sci } || species_list.first
          base_entry("lump", first_species, first_taxon).except(:code, :species).merge(
            into: target_code,
            name_sci: target&.name_sci,
            name_en: target&.name_en,
            species: species_list.map(&:name_sci),
            survivor: survivor.name_sci,
            observation_count: species_list.sum { |sp| species_observation_count(sp) }
          ).except(:by_country)
        end
      end

      def rename_entry(species, taxon, old, new)
        changes = renames(species, old, new)
        base_entry("rename", species, taxon).except(:by_country).merge(changes) if changes.any?
      end

      # Only names eBird itself changed; my deliberate differences from eBird are left alone.
      def renames(species, old, row)
        changes = {}
        if old.name_sci != row.name_sci && species.name_sci != row.name_sci
          changes[:name_sci] = { old: species.name_sci, new: row.name_sci }
        end
        if old.name_en != row.name_en && species.name_en != row.name_en
          hyphen_only = row.name_en.sub(HYPHEN_ONLY, '\1\2 \3') == species.name_en
          unless hyphen_only && species.name_en_overwritten
            changes[:name_en] = {
              old: species.name_en, new: row.name_en,
              accept: !(hyphen_only || species.name_en_overwritten),
            }
          end
        end
        changes
      end

      # Removed non-species taxa that still carry observations need a new home.
      def removed_taxa_entries
        my_taxa.filter_map do |tx|
          next if tx.category == "species" && tx.species_id
          next if @source[tx.ebird_code] || !observation_counts[tx.id] || !ebird_taxa[tx.ebird_code]

          same_concept = tx.taxon_concept_id ? @source.with_concept(tx.taxon_concept_id) : []
          type = same_concept.size == 1 ? "code_change" : "ambiguous"
          {
            _index: tx.index_num, type: type, status: "draft", code: tx.ebird_code, taxon: tx.name_sci,
            observation_count: observation_counts[tx.id],
            new_code: same_concept.first&.code, candidates: same_concept.map(&:code),
          }.compact_blank
        end
      end

      # New species that the old taxon's concept went into, with the signal that found each.
      def daughters_for(old)
        return [] unless old

        found = {}
        add = ->(row, signal) { found[row.code] ||= daughter(row, signal) if row&.species? }

        add.call(@source[old.ebird_code], "code") if concept_changed?(old, @source[old.ebird_code])
        old.children.each { |child| add.call(@source.species_for(child.ebird_code), "children") }
        @source.species_named(old.name_sci).each { |row| add.call(row, "name") }
        new_slashes_including(old.name_sci).each do |slash|
          Source.slash_names(slash.name_sci).each do |name|
            @source.species_named(name).each { |row| add.call(row, "slash") }
          end
        end
        found.values
      end

      # Slashes added this year; old ones would pair the species with long-known neighbours.
      def new_slashes_including(name_sci)
        slashes = @source.slashes_including(name_sci)
        existing = EBirdTaxon.where(ebird_code: slashes.map(&:code)).pluck(:ebird_code)
        slashes.reject { |s| s.code.in?(existing) }
      end

      def daughter(row, signal)
        { code: row.code, name_sci: row.name_sci, name_en: row.name_en, matched_by: signal }
      end

      def concept_changed?(old, new)
        old&.taxon_concept_id.present? && new&.concept.present? &&
          Source.normalize_concept(old.taxon_concept_id) != new.concept
      end

      def base_entry(type, species, taxon)
        {
          _index: taxon.index_num, type: type, status: "draft", code: taxon.ebird_code, species: species.name_sci,
          observation_count: species_observation_count(species), by_country: by_country(species),
        }
      end

      def species_observation_count(species)
        species_observation_counts[species.id] || 0
      end

      def by_country(species)
        counts = Observation.joins(:card).where(species_id: species.id).group("cards.locus_id").count
        countries = Locus.country_slug_by_id(Locus.where(id: counts.keys))
        counts.each_with_object(Hash.new(0)) { |(locus_id, n), acc| acc[countries[locus_id] || "unknown"] += n }
          .sort_by { |_, n| -n }.to_h
      end

      def my_taxa
        @my_taxa ||= Taxon.order(:index_num).to_a
      end

      def ebird_taxa
        @ebird_taxa ||= EBirdTaxon.where(ebird_code: my_taxa.map(&:ebird_code)).includes(:children).index_by(&:ebird_code)
      end

      def observation_counts
        @observation_counts ||= Observation.group(:taxon_id).count
      end

      def species_observation_counts
        @species_observation_counts ||= Observation.group(:species_id).count
      end
    end
  end
end
