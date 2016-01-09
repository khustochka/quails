module NewLifelist
  class Advanced < Factory

    KEYS = [
        :first_seen,
        :last_seen,
        :obs_count
    ]

    delegate :each, :size, :blank?, to: :to_a

    def to_a
      primary_list.map do |obs|
        species = obs.species
        result = FullLifer.new(species)

        # Put the primary value in place
        result.set(primary_key, obs)

        KEYS.each do |key|
          # If not yet filled (secondary values) fill it (indexed by species)
          if result.get(key).nil?
            val = if key == :obs_count
                    secondary_list(key)[species.id].obs_count
                  else
                    secondary_list(key)[species.id]
                  end
            result.set(key, val)
          end
        end

        result
      end
    end

    private
    def primary_list
      @primary_list ||= all_lists(primary_key).sort(@sorting)
    end

    def primary_key
      @primary_key ||= case @sorting
        when nil, "class"
          then :first_seen
        when "last"
          then :last_seen
        when "count"
          then :obs_count
        else
          raise "Invalid sorting key."
      end
    end

    def all_lists(key)
      @all_lists ||= {}
      @all_lists[key] ||= case key
                            when :first_seen
                              then NewLifelist::FirstSeen.over(@filter)
                            when :last_seen
                              then NewLifelist::LastSeen.over(@filter)
                            when :obs_count
                              then NewLifelist::Count.over(@filter)
                          end
    end

    def secondary_list(key)
      @secondary_list ||= {}
      @secondary_list[key] ||= all_lists(key).bare_relation.index_by {|ob| ob.species_id }
    end

  end
end
