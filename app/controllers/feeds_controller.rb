class FeedsController < ApplicationController
  respond_to :xml

  caches_page :blog, :photos, :sitemap, :gzip => true

  def blog
    @posts = Post.public.order('face_date DESC').limit(10)
  end

  def photos
    @photos = Image.order('created_at DESC').preload(:species, :observations => {:card => :locus}).limit(15)
  end

  def sitemap
    @posts = Post.indexable.select("slug, face_date, updated_at")
    @images = Image.select("id, slug, created_at")
    @species = Species.where(id: Observation.select(:species_id)).select("id, name_sci")

    # TODO: take into account only the posts shown on home page
    @root_lastmod = Post.public.order('updated_at DESC').first.updated_at.iso8601 rescue nil
  end
end
