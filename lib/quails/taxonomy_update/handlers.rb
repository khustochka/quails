# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Manifest entry handlers, by type. See Handler for the lifecycle.
    module Handlers
      # name_sci: {old, new}; name_en: {old, new, accept}; extra: {attr: value}
      class Rename < Handler
        def apply
          species = my_species(entry.fetch("species"))
          rename_species(species, entry.dig("name_sci", "new")) if entry["name_sci"]
          if (en = entry["name_en"])
            if en["accept"]
              species.update!(name_en: en.fetch("new"))
              log("English name: #{en.fetch("new")}")
            else
              species.update!(name_en_overwritten: true)
            end
          end
          apply_extra(species, entry["extra"])
        end
      end

      # code -> new_code, same concept. Species entries (species:) are relinked and may
      # carry renames; taxon entries (taxon:) only move observations.
      class CodeChange < Rename
        def prepare
          move_observations(Observation.where(taxon: taxon(entry.fetch("code"))), entry.fetch("new_code"))
        end

        def apply
          return unless entry["species"]

          relink(my_species(entry["species"]), taxon(entry["new_code"]))
          super
        end
      end

      # survivor:      daughter code that keeps my species record (renamed if its names differ)
      # observations:  {all: code} or {by_locus: {slug: code}, default: code | "leave"}
      #                for observations on the old species-rank taxon; the deepest locus wins
      # local_species: {slug: code}
      # create:        [code] daughters to give a record even without observations
      # extra:         {code: {attr: value}}
      #
      # Every daughter other than the survivor that gets observations, local_species or
      # create: gets a record, linked to the survivor by SpeciesSplit.
      class Split < Handler
        RULE_KEYS = %w[all by_locus default].freeze

        def prepare
          fail!("survivor is not set") if survivor_code.blank?
          unknown = rule.keys - RULE_KEYS
          fail!("unknown observations keys: #{unknown.join(", ")}") if unknown.any?

          target_codes.each do |code|
            fail!("#{code} is not a species") unless ensure_taxon(code).category == "species"
          end
          move_split_observations
        end

        def apply
          record = my_species(entry.fetch("species"))
          survivor = taxon(survivor_code)
          rename_species(record, survivor.name_sci, name_en: survivor_name_en(record, survivor), reason: "split")
          relink(record, survivor)

          by_code = { survivor_code => record }
          (target_codes - [survivor_code]).each do |code|
            tx = taxon(code)
            species = Species.where.not(id: record.id).find_by(name_sci: tx.name_sci) || create_species(tx)
            relink(species, tx)
            SpeciesSplit.find_or_create_by!(superspecies: record, subspecies: species)
            by_code[code] = species
          end

          move_local_species(record, by_code)
          by_code.each_value { |species| fix_image(species) }
          (entry["extra"] || {}).each do |code, attrs|
            apply_extra(by_code[code] || fail!("extra for #{code}, which gets no record"), attrs)
          end
        end

        private

        def survivor_code = entry["survivor"]

        def rule = entry["observations"] || {}

        def target_codes
          codes = [survivor_code, rule["all"], *rule["by_locus"]&.values, rule["default"],
            *entry["local_species"]&.values, *entry["create"],]
          codes.compact.uniq - ["leave"]
        end

        def move_split_observations
          scope = Observation.where(taxon: taxon(entry.fetch("code")))
          return if scope.none?

          if rule["all"]
            move_observations(scope, rule["all"])
          elsif rule["by_locus"]
            move_by_locus(scope)
          elsif EBirdTaxon.where(ebird_code: entry["code"], ebird_version: context.version, category: "species").none?
            fail!("#{scope.count} observations on #{entry["code"]} need an observations rule")
          end
        end

        def move_by_locus(scope)
          code_by_locus = locus_rules(rule["by_locus"])
          groups = scope.joins(:card).pluck(:id, "cards.locus_id").group_by { |_, locus_id| code_by_locus[locus_id] }
          unmatched = groups.delete(nil)
          groups.each { |code, rows| move_observations(Observation.where(id: rows.map(&:first)), code) }
          return unless unmatched

          case rule["default"]
          when nil
            countries = Locus.country_slug_by_id(Locus.where(id: unmatched.map(&:last))).values.tally
            fail!("#{unmatched.size} observations match no locus rule: #{countries.inspect}")
          when "leave"
            log("left #{unmatched.size} observations on #{entry["code"]}")
          else
            move_observations(Observation.where(id: unmatched.map(&:first)), rule["default"])
          end
        end

        # locus_id => code; deeper loci override their ancestors.
        def locus_rules(by_locus)
          loci = Locus.where(slug: by_locus.keys).index_by(&:slug)
          missing = by_locus.keys - loci.keys
          fail!("unknown loci: #{missing.join(", ")}") if missing.any?

          by_locus.sort_by { |slug, _| loci[slug].depth }.each_with_object({}) do |(slug, code), map|
            loci[slug].subtree_ids.each { |id| map[id] = code }
          end
        end

        def move_local_species(record, by_code)
          (entry["local_species"] || {}).each do |slug, code|
            locus = Locus.find_by(slug: slug) || fail!("unknown locus #{slug}")
            target = by_code.fetch(code)
            next if target == record

            LocalSpecies.where(locus: locus, species: record).find_each do |ls|
              LocalSpecies.exists?(locus: locus, species: target) ? ls.destroy! : ls.update!(species: target)
            end
            log("local species at #{slug} -> #{target.name_sci}")
          end
        end
      end

      # into: code of the species they merge into; species: [my name_sci]; survivor: name_sci
      # of the record that stays (renamed to the merged name). Others are merged and deleted.
      class Lump < Handler
        def prepare
          ensure_taxon(entry.fetch("into"))
        end

        def apply
          target = taxon(entry["into"])
          survivor = my_species(entry.fetch("survivor"))
          lumped = Array(entry["species"]).map { |name| my_species(name) } - [survivor]

          rename_species(survivor, target.name_sci, name_en: survivor_name_en(survivor, target))
          relink(survivor, target)
          lumped.each { |species| merge(species, survivor) }
          fix_image(survivor)
          apply_extra(survivor, entry["extra"])
        end

        private

        def merge(species, survivor)
          species.local_species.each do |ls|
            LocalSpecies.exists?(locus_id: ls.locus_id, species: survivor) ? ls.destroy! : ls.update!(species: survivor)
          end
          species.url_synonyms.update_all(species_id: survivor.id)
          species.taxa.find_each { |tx| tx.update!(species_id: nil) }
          species.species_image&.destroy!
          name = species.name_sci
          species.reload.destroy!
          add_synonym(name, survivor, "lump")
          log("merged #{name} into #{survivor.name_sci}")
        end
      end
    end
  end
end
