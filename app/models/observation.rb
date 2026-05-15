# frozen_string_literal: true

class Observation < ApplicationRecord
  include DecoratedModel

  invalidates Quails::CacheKey.lifelist

  belongs_to :card, touch: true, inverse_of: :observations

  belongs_to :taxon

  # FIXME: do not use this!! (See MyObservation for more comments)
  # belongs_to :species
  # NOTE: Do not use .includes(:taxon), it breaks species preloading, use .preload

  def species
    taxon.species
  end

  belongs_to :post_core, touch: true, optional: true, inverse_of: :observations
  has_and_belongs_to_many :media
  has_and_belongs_to_many :images, class_name: "Image", association_foreign_key: :media_id
  has_and_belongs_to_many :videos, class_name: "Video", association_foreign_key: :media_id
  has_many :spots, dependent: :delete_all

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError, self.class.reflections[:images]
    end
    if videos.present?
      raise ActiveRecord::DeleteRestrictionError, self.class.reflections[:videos]
    end
  end

  # Scopes

  scope :identified, lambda { joins(:taxon).merge(Taxon.listable) }

  scope :not_hidden, -> { where(hidden: false) }

  def self.count_distinct_species
    count("DISTINCT species_id")
  end

  def self.refine(options = {})
    rel = all
    if options[:winter]
      if (year = options[:year])
        first_day = Date.new(year.to_i, 12, 1)
        last_day = Date.new(year.to_i + 1, 3, 1) - 1.day
        rel = rel.joins(:card).where("cards.observ_date BETWEEN ? AND ?", first_day, last_day)
      else
        rel = rel.joins(:card).where("EXTRACT(month from cards.observ_date)::integer IN (12, 1, 2)")
      end
    else
      rel = rel.joins(:card).where("EXTRACT(year from cards.observ_date)::integer = ?", options[:year]) if options[:year].present?
      rel = rel.joins(:card).where("EXTRACT(month from cards.observ_date)::integer = ?", options[:month]) if options[:month].present?
      rel = rel.joins(:card).where("EXTRACT(day from cards.observ_date)::integer = ?", options[:day]) unless options[:day].blank? || options[:month].blank?
    end
    rel = rel.joins(:card).where(cards: { locus_id: options[:locus] }) if options[:locus].present?
    rel = rel.joins(:card).where(cards: { motorless: true }) if options[:motorless]
    rel = rel.joins(:card).where(voice: false) if options[:exclude_heard_only]
    rel
  end

  def self.years
    joins(:card).order(:year).distinct.pluck(Arel.sql("EXTRACT(year from observ_date)::integer AS year"))
  end

  # Species

  def observ_date
    read_attribute(:observ_date) || card.observ_date
  end

  def locus
    card.locus
  end

  # Returns a Post (single translation) for views that need to link to a blog
  # post. Lifelist preloader replaces this with the locale-correct sibling
  # (may explicitly set nil to hide private siblings).
  #
  # Resolution order:
  #   1. explicitly-set @main_post (e.g. from Lifelist preloader)
  #   2. main_post_core's first translation (own core, or card's core)
  #   3. card.main_post (in case the card was preloaded but obs.post_core is unset)
  def main_post
    return @main_post if defined?(@main_post)

    @main_post = if post_core
      post_core.posts.first
    else
      card&.main_post
    end
  end

  attr_writer :main_post

  def main_post_core
    post_core || card.post_core
  end

  # Bridge: same as Card#post=. Translates `post: a_post` into "attach to
  # that post's core". TODO: remove in Phase 4.
  def post=(blogpost)
    self.post_core = blogpost&.post_core
  end

  def post
    main_post
  end

  def significant_value_for_lifelist
    # If it were observation count it's significant value is the count otherwise it is observation itself
    if self[:obs_count]
      obs_count
    else
      self
    end
  end
end
