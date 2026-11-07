# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # A reviewed change manifest (lib/tasks/taxonomy/YEAR/changes.yml) as written by Differ.
    class Manifest
      STATUSES = %w[draft ok skip].freeze

      attr_reader :entries

      def self.load(path)
        new(YAML.safe_load_file(path))
      end

      def initialize(data)
        @entries = (data || {}).fetch("entries", [])
      end

      def applicable
        entries.select { |e| e["status"] == "ok" }
      end

      # Reasons the manifest cannot be applied with handlers for +known_types+.
      def errors(known_types)
        entries.filter_map do |e|
          label = "#{e["type"]} #{e["code"] || e["into"]}"
          if e["status"] == "draft"
            "#{label}: still draft"
          elsif !e["status"].in?(STATUSES)
            "#{label}: unknown status #{e["status"].inspect}"
          elsif e["status"] == "ok" && !e["type"].in?(known_types)
            "#{label}: no handler for type #{e["type"].inspect}"
          end
        end
      end
    end
  end
end
