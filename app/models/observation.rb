# frozen_string_literal: true

class Observation < ApplicationRecord
  include DecoratedModel

  invalidates CacheKey.lifelist

  belongs_to :card, touch: true, inverse_of: :observations

  belongs_to :taxon

  # FIXME: do not use this!! (See MyObservation for more comments)
  #belongs_to :species
  # NOTE: Do not use .includes(:taxon), it breaks species preloading, use .preload

  def species
    taxon.species
  end

  belongs_to :post, -> { short_form }, touch: true, optional: true
  has_and_belongs_to_many :media
  has_and_belongs_to_many :images, class_name: "Image", association_foreign_key: :media_id
  has_and_belongs_to_many :videos, class_name: "Video", association_foreign_key: :media_id
  has_many :spots, dependent: :delete_all
  belongs_to :patch, class_name: "Locus", foreign_key: "patch_id", optional: true

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
    if videos.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:videos])
    end
  end

  validates :taxon_id, presence: true

  # Scopes

  scope :identified, lambda { joins(:taxon).merge(Taxon.listable) }

  def self.count_distinct_species
    self.count("DISTINCT species_id")
  end

  def self.refine(options = {})
    rel = self.all
    rel = rel.joins(:card).where("EXTRACT(year from cards.observ_date)::integer = ?", options[:year]) unless options[:year].blank?
    rel = rel.joins(:card).where("EXTRACT(month from cards.observ_date)::integer = ?", options[:month]) unless options[:month].blank?
    rel = rel.joins(:card).where("EXTRACT(day from cards.observ_date)::integer = ?", options[:day]) unless options[:day].blank? || options[:month].blank?
    rel = rel.joins(:card).where("cards.locus_id IN (?) OR observations.patch_id IN (?)", options[:locus], options[:locus]) unless options[:locus].blank?
    rel
  end

  def self.years
    joins(:card).order("year").distinct.pluck(Arel.sql("EXTRACT(year from observ_date)::integer AS year"))
  end

  # Species

  def observ_date
    read_attribute(:observ_date) || card.observ_date
  end

  def patch_or_locus
    patch || card.locus
  end

  def main_post
    post || card.post
  end

  def significant_value_for_lifelist
    # If it were observation count it's significant value is the count otherwise it is observation itself
    if read_attribute(:obs_count)
      obs_count
    else
      self
    end
  end

end
