# frozen_string_literal: true

require "csv"

module Quails
  module TaxonomyUpdate
    # A parsed eBird taxonomy CSV. Reads both the older (TAXON_CONCEPT_ID, REPORT_AS)
    # and the 2026+ (bio_concept_code, sparse_report_as) column layouts.
    class Source
      Row = Data.define(:code, :category, :concept, :name_en, :name_sci, :order, :family, :parent_code, :taxon_order) do
        def species? = category == "species"
      end

      # Candidate headers per field, in order of preference (lowercased).
      COLUMNS = {
        code: %w[species_code],
        category: %w[category],
        concept: %w[bio_concept_code taxon_concept_id],
        name_en: %w[primary_com_name],
        name_sci: %w[sci_name],
        order: %w[order1 order],
        family: %w[family],
        parent_code: %w[sparse_report_as report_as],
        taxon_order: %w[taxon_order],
      }.freeze

      attr_reader :rows

      # Avibase concept ids appear as "avibase-X", "avibase-avibase-X" or bare "X".
      def self.normalize_concept(value)
        value.to_s.sub(/\A(?:avibase-)+/, "").presence
      end

      def self.read(path)
        new(File.read(path, encoding: "bom|utf-8"))
      end

      def initialize(csv_text)
        table = CSV.parse(csv_text, headers: true, header_converters: ->(h) { h.delete_prefix("﻿").strip.downcase })
        columns = resolve_columns(table.headers)
        @rows = table.map { |line| build_row(line, columns) }
        @by_code = @rows.index_by(&:code)
        @children = @rows.group_by(&:parent_code)
        @by_concept = @rows.select(&:concept).group_by(&:concept)
        @species_by_name = @rows.select(&:species?).group_by(&:name_sci)
        @slashes_by_name = @rows.select { |r| r.category == "slash" }
          .flat_map { |r| self.class.slash_names(r.name_sci).map { |name| [name, r] } }
          .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
      end

      # "Erithacus rubecula/superbus" => ["Erithacus rubecula", "Erithacus superbus"].
      # Empty for slashes that are not between binomials (e.g. genus or group slashes).
      def self.slash_names(name_sci)
        first, *rest = name_sci.to_s.split("/")
        genus = first.to_s.split.first
        names = [first, *rest.map { |part| part.include?(" ") ? part : "#{genus} #{part}" }]
        names.all? { |n| n.match?(/\A[A-Z][a-z]+ [a-z]+\z/) } ? names : []
      end

      def [](code)
        @by_code[code]
      end

      def codes
        @by_code.keys
      end

      def children_of(code)
        @children[code] || []
      end

      def with_concept(concept)
        @by_concept[self.class.normalize_concept(concept)] || []
      end

      def species_named(name_sci)
        @species_by_name[name_sci] || []
      end

      def slashes_including(name_sci)
        @slashes_by_name[name_sci] || []
      end

      # The species-rank row a taxon reports to (itself if it is a species).
      def species_for(code)
        row = self[code]
        row = self[row.parent_code] while row && !row.species? && row.parent_code
        row if row&.species?
      end

      private

      def resolve_columns(headers)
        COLUMNS.transform_values do |candidates|
          candidates.find { |c| headers.include?(c) } || raise(ArgumentError, "eBird CSV has none of: #{candidates.join(", ")}")
        end
      end

      def build_row(line, columns)
        Row.new(
          code: line[columns[:code]],
          category: line[columns[:category]],
          concept: self.class.normalize_concept(line[columns[:concept]]),
          name_en: line[columns[:name_en]],
          name_sci: line[columns[:name_sci]],
          order: line[columns[:order]],
          family: line[columns[:family]],
          parent_code: line[columns[:parent_code]].presence,
          taxon_order: line[columns[:taxon_order]]
        )
      end
    end
  end
end
