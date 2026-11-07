# frozen_string_literal: true

module Quails
  module TaxonomyUpdate
    # Base for per-type manifest entry handlers; also the no-op handler for concept_change.
    #
    # Applier calls, for every `status: ok` entry:
    #   #prepare - after eBird taxa are imported, before taxa are re-synced
    #              (promote new eBird taxa, move observations between taxa)
    #   #apply   - after taxa are re-synced (species records, splits, synonyms, images)
    class Handler
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
    end
  end
end
