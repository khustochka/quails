class FeedsController < ApplicationController

  caches_page :blog, :photos, :sitemap, :gzip => true

  def blog
    @posts = Post.public_posts.order(face_date: :desc).limit(10)
  end

  def photos
    @media =
        [Image, Video].flat_map do |klass|
          klass.order(created_at: :desc).preload(:species, :observations => {:card => :locus}).limit(10)
        end.sort { |x,y| y.created_at <=> x.created_at }
  end

  def sitemap
    @posts = Post.indexable.select("slug, face_date, updated_at")
    @images = Image.indexable.select("id, slug, created_at")
    @species = Species.where(id: Observation.select(:species_id)).select("id, name_sci")

    # TODO: take into account only the posts shown on home page
    @root_lastmod = Post.public_posts.order(updated_at: :desc).first.updated_at.iso8601 rescue nil
  end
end
