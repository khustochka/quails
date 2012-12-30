module Legacy
  module Mapping

    class << self
      attr_reader :species, :posts, :locations, :spots
    end

    def self.refresh_species
      @species = Hash[Species.to_a.map { |sp| [sp.code, sp.id] }]
    end

    def self.refresh_posts
      @posts = Hash[Post.to_a.map { |p| [p.slug, p.id] }]
    end

    def self.refresh_locations
      @locations = Hash[Locus.to_a.map { |loc| [loc.slug, loc.id] }]
    end

    def self.add_spot(ob_id, mark_id, new_id)
      @spots ||= {}
      @spots["#{ob_id}#{mark_id}"] = new_id
    end

  end
end
