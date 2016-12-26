module Lifelist
  class Factory

    include Enumerable

    def self.over(options)
      new(options)
    end

    def self.full
      new({})
    end

    def initialize(options = {})
      @filter = options.to_h.with_indifferent_access
    end

    def set_posts_scope(posts_scope)
      @posts_scope = posts_scope
      self
    end

    def sort(sorting)
      @sorting = sorting
      self
    end

    def years
      @years ||= [nil] + MyObservation.filter(normalized_filter.merge({year: nil})).years
    end

    def locus
      @locus ||= if @filter[:locus]
                   Locus.find_by_slug(@filter[:locus])
                 else
                   nil
                 end
    end

    def normalized_filter
      @normalized_filter ||= @filter.dup.tap do |filter|
        if filter[:locus]
          filter[:locus] = Locus.find_by!(slug: filter[:locus]).subregion_ids
        end
      end
    end

  end
end
