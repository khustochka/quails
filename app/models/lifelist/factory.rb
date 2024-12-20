# frozen_string_literal: true

module Lifelist
  class Factory
    include Enumerable

    attr_writer :posts_scope, :observation_scope

    def self.over(options)
      new(options)
    end

    def self.full
      new({})
    end

    def initialize(options = {})
      @filter = options.to_h.with_indifferent_access
    end

    def sort(sorting)
      @sorting = sorting
      self
    end

    def years
      @years ||= [nil] + MyObservation.refine(normalized_filter.merge({ year: nil, motorless: nil, exclude_heard_only: nil })).years
    end

    def locus
      @locus ||= if @filter[:locus]
        Locus.find_by(slug: @filter[:locus])
      end
    end

    def normalized_filter
      @normalized_filter ||= @filter.dup.tap do |filter|
        if filter[:locus]
          filter[:locus] = locus&.subregion_ids
        end
      end
    end
  end
end
