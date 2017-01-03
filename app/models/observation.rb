class Observation < ApplicationRecord
  include DecoratedModel

  invalidates CacheKey.lifelist

  belongs_to :card, touch: true

  belongs_to :taxon
  belongs_to :legacy_species

  # FIXME: do not use this!! (See MyObservation for more comments)
  #belongs_to :species
  # NOTE: Do not use .includes(:taxon), it breaks species preloading, use .preload

  def species
    taxon.species
  end

  belongs_to :post, -> { short_form }, touch: :updated_at
  has_and_belongs_to_many :media
  has_and_belongs_to_many :images, class_name: 'Image', association_foreign_key: :media_id
  has_and_belongs_to_many :videos, class_name: 'Video', association_foreign_key: :media_id
  has_many :spots, dependent: :delete_all
  belongs_to :patch, class_name: 'Locus', foreign_key: 'patch_id'

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  validates :taxon_id, presence: true

  # Scopes

  scope :identified, lambda { joins(:taxon).where("taxa.species_id IS NOT NULL") }

  def self.count_distinct_species
    self.count("DISTINCT species_id")
  end

  # TODO: improve and probably use universally
  def self.filter(options = {})
    rel = self.all
    rel = rel.joins(:card).where('EXTRACT(year from cards.observ_date)::integer = ?', options[:year]) unless options[:year].blank?
    rel = rel.joins(:card).where('EXTRACT(month from cards.observ_date)::integer = ?', options[:month]) unless options[:month].blank?
    rel = rel.joins(:card).where('cards.locus_id IN (?) OR observations.patch_id IN (?)', options[:locus], options[:locus]) unless options[:locus].blank?
    rel
  end

  def self.years
    joins(:card).order('year').pluck('DISTINCT EXTRACT(year from observ_date)::integer AS year')
  end

  # Species

  delegate :species_str, :when_where_str, to: :decorated

  def observ_date
    if d = read_attribute(:observ_date)
      d
    else
      card.observ_date
    end
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
