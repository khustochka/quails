class NewLifelist
  class PublicPostPreloader < ActiveRecord::Associations::Preloader

    def preloader_for(reflection, owners, rhs_klass)

      if owners.first.association(reflection.name).loaded?
        return AlreadyLoaded
      end
      reflection.check_preloadable!

      if rhs_klass == Post
        return PublicPostAssociation
      else
        raise "PublicPostPreloader should only be used to preload posts!"
      end

    end

    class PublicPostAssociation < BelongsTo

      def reflection_scope
        @reflection_scope ||= Post.public_posts
      end

    end

  end
end
