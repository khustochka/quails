class Observation < ActiveRecord::Base
  include FormattedModel

  sweep_cache :lifelist

  belongs_to :card

  belongs_to :species
  belongs_to :post, -> { select(:id, :slug, :face_date, :title, :status) }
  has_and_belongs_to_many :images
  has_many :spots

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  validates :species_id, :presence => true

  # Scopes

  scope :identified, lambda { where('observations.species_id != 0') }

  # TODO: improve and probably use universally
  def self.filter(options = {})
    rel = self.all
    rel = rel.joins(:card).where('EXTRACT(year from cards.observ_date)::integer = ?', options[:year]) unless options[:year].blank?
    rel = rel.joins(:card).where('EXTRACT(month from cards.observ_date)::integer = ?', options[:month]) unless options[:month].blank?
    rel = rel.joins(:card).where('cards.locus_id' => options[:locus]) unless options[:locus].blank?
    rel
  end

  def self.years
    joins(:card).order('year').pluck('DISTINCT EXTRACT(year from observ_date)::integer AS year')
  end

  # Species

  alias_method :real_species, :species

  def species
    species_id == 0 ?
        Species::AVIS_INCOGNITA :
        real_species
  end

  delegate :species_str, :when_where_str, to: :formatted

end
