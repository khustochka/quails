# frozen_string_literal: true

module Lifelist
  class FullLifer
    attr_accessor :species, :first_seen, :last_seen, :obs_count

    def initialize(sp)
      self.species = sp
    end

    def get(key)
      send(key)
    end

    def set(key, val)
      send("#{key}=", val)
    end

    # Behave as species for taxonomy sorting
    delegate :order, :family, to: :species

    def same_date?
      first_seen.observ_date == last_seen.observ_date
    end
  end
end
