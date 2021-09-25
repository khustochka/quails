# frozen_string_literal: true

module Search
  class PublicSpeciesSearch < SpeciesSearch
    SEARCH_RESULT_CLASS = PublicSpeciesSearchResult

    def initialize(base, term)
      super(base, term, {})
    end
  end
end
