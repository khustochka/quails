# frozen_string_literal: true

module Search
  class PublicSpeciesSearchResult < SpeciesSearchResult
    private
    def json_default_options
      {only: [:name], methods: [:label, :url]}
    end
  end
end
