module NewLifelist
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

  end
end

