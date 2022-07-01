# frozen_string_literal: true

module Search
  class PublicSpeciesSearchResult < SpeciesSearchResult
    private

    def json_default_options
      { methods: [:name, :label, :url] }
    end
  end
end
