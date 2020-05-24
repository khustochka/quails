module Deflicker
  class Search

    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :public, :boolean

    def self.model_name
      ActiveModel::Name.new(self, nil, "Q")
    end

    def persisted?
      false
    end

    def result
      base = Flicker.all
      unless public.nil?
        base = base.where(public: public)
      end
      base
    end

  end
end
