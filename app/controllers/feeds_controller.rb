class FeedsController < ApplicationController
  respond_to :xml

  def blog
    @posts = Post.public.order('face_date DESC').limit(10)
  end

  def sitemap
    @posts = Post.public.select("code, face_date, updated_at")
    @images = Image.preload(:species).select("id, code, created_at")
    @species = Species.joins("RIGHT JOIN observations ON species.id = species_id").where('species.id != 0').
        uniq.select('name_sci').reorder(nil)

    # TODO; take into account only the posts shown on home page
    @root_lastmod = Post.order('updated_at DESC').limit(1).first.updated_at.iso8601 rescue nil
  end
end