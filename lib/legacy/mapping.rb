module Legacy
  module Mapping

    class << self
      attr_reader :species, :posts, :locations
    end

    def self.refresh_species
      @species = Hash[Species.all.map { |sp| [sp.code, sp.id] }]
    end

    def self.refresh_posts
      @posts = Hash[Post.all.map { |p| [p.slug, p.id] }]
    end

    def self.refresh_locations
      @locations = Hash[Locus.all.map { |loc| [loc.slug, loc.id] }]
    end

  end
end
