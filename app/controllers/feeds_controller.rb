# frozen_string_literal: true

class FeedsController < ApplicationController

  caches_page :blog, :photos, :sitemap, gzip: true
  caches_page :instant_articles, gzip: true, unless: -> { params[:dev] }

  def blog
    @posts = Post.public_posts.order(face_date: :desc).limit(10)
  end

  def instant_articles
    @dev = params[:dev]
    @posts = Post.facebook_publishable.order(face_date: :desc).limit(15)
  end

  def photos
    @media = Media.order(created_at: :desc).preload(:species, :cards, :observations => {:card => :locus}).limit(15)
  end

  def sitemap
    @posts = Post.indexable.select("slug, face_date, updated_at")
    @images = Image.indexable.select("id, slug, updated_at")
    @videos = Video.select("id, slug, updated_at")
    @species = Species.where(id: Observation.joins(:taxon).select(:species_id)).select("id, name_sci")

    @root_lastmod = Post.public_posts.order(updated_at: :desc).first.updated_at.iso8601 rescue nil
  end
end
