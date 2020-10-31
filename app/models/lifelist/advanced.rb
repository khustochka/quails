# frozen_string_literal: true

module Lifelist
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
        result.set(primary_key, obs.significant_value_for_lifelist)

        KEYS.each do |key|
          # If not yet filled (secondary values) fill it (indexed by species)
          if result.get(key).nil?
            val = secondary_list(key)[species.id].significant_value_for_lifelist
            result.set(key, val)
          end
        end

        result
      end
    end

    # Behave as species array for taxonomy sorting. FullLifer should respond to order, family
    include SpeciesArray

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
      return @all_lists[key] if @all_lists[key]
      list = case key
             when :first_seen
                              then Lifelist::FirstSeen.over(@filter)
             when :last_seen
                              then Lifelist::LastSeen.over(@filter)
             when :obs_count
                              then Lifelist::Count.over(@filter)
             end
      list.set_posts_scope(@posts_scope)
    end

    def secondary_list(key)
      @secondary_list ||= {}
      @secondary_list[key] ||= all_lists(key).short_to_a.index_by {|ob| ob.species_id }
    end

  end
end
