class Observation < ActiveRecord::Base
  include FormattedModel

  invalidates CacheKey.lifelist

  belongs_to :card, touch: true

  belongs_to :species
  belongs_to :post, -> { select(:id, :slug, :face_date, :title, :status) }, touch: :updated_at
  has_and_belongs_to_many :images
  has_and_belongs_to_many :videos, join_table: 'videos_observations'
  has_many :spots, dependent: :delete_all
  belongs_to :patch, class_name: 'Locus', foreign_key: 'patch_id'

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  validates :species_id, :presence => true

  # Scopes

  scope :identified, lambda { where('observations.species_id != 0') }

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

  def species_with_incognita
    species_id == 0 ?
        Species::AVIS_INCOGNITA :
        species_without_incognita
  end

  alias_method_chain :species, :incognita

  delegate :species_str, :when_where_str, to: :formatted

  def patch_or_locus
    patch || card.locus
  end

end
