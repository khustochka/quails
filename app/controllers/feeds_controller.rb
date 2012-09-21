class FeedsController < ApplicationController
  respond_to :xml

  caches_page :blog, :photos, :sitemap

  def blog
    @posts = Post.public.order('face_date DESC').limit(10)
  end

  def photos
    @photos = Image.order('created_at DESC').preload(:species, :observations).limit(15)
  end

  def sitemap
    @posts = Post.public.select("slug, face_date, updated_at")
    @images = Image.preload(:species).select("id, slug, created_at")
    @species = Species.joins(:observations).where('species.id != 0').
        uniq.select('legacy_slug')

    # TODO: take into account only the posts shown on home page
    @root_lastmod = Post.public.order('updated_at DESC').limit(1).first.updated_at.iso8601 rescue nil
  end
end
