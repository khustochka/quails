module Legacy
  class Mapping

    class << self
      attr_reader :species, :posts, :locations
    end

    def self.refresh_species
      @species = Hash[Species.all.map { |sp| [sp.code, sp.id] }]
    end

    def self.refresh_posts
      @posts = Hash[Post.all.map { |p| [p.code, p.id] }]
    end

    def self.refresh_locations
      @locations = Hash[Locus.all.map { |loc| [loc.code, loc.id] }]
    end

  end
end