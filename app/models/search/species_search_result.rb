# frozen_string_literal: true

module Search
  class SpeciesSearchResult < Struct.new(:name_sci, :name)
    include ActiveModel::Serializers::JSON
    include ActiveModel::Attributes

    def attributes
      { "name" => name, "name_sci" => name_sci }
    end

    def as_json(options = nil)
      opts = options || {}
      super(json_default_options.merge(opts))
    end

    def label
      name_sci
    end

    def url
      # FIXME: Do not rely on I18n. There must be some decorator
      locale_prefix = (I18n.locale == I18n.default_locale) ? "" : "/#{I18n.locale}"
      "#{locale_prefix}/species/#{Species.parameterize(name_sci)}"
    end

    private
    def json_default_options
      {only: [:name], methods: [:label]}
    end
  end
end
