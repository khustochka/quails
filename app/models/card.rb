class Card < ActiveRecord::Base

  EFFORT_TYPES = %w(UNSET INCIDENTAL TRAVEL AREA)

  include FormattedModel

  include ActiveSupport::NumberHelper

  invalidates CacheKey.lifelist

  belongs_to :locus
  belongs_to :post, touch: :updated_at
  has_many :observations, -> { order('observations.id') }, dependent: :restrict_with_exception
  has_many :images, through: :observations
  has_many :species, -> { order(:index_num) }, through: :observations
  has_many :spots, through: :observations

  validates :locus_id, :observ_date, presence: true
  validates :effort_type, inclusion: EFFORT_TYPES, allow_blank: false

  accepts_nested_attributes_for :observations,
                                reject_if:
                                    proc { |attrs| attrs.all? { |k, v| v.blank? || k == 'voice' } }

  def secondary_posts
    Post.uniq.joins(:observations).where('observations.card_id = ? AND observations.post_id <> ?', self.id, self.post_id)
  end

  def mapped?
    spots.any?
  end

  def mapped_observations
    self.observations.joins(:spots).uniq
  end

  def mapped_percentage
    number_to_percentage(mapped_observations.count * 100.0 / observations.count, precision: 0)
  end

  # List of new species
  def new_species_ids
    subquery = "select obs.id from observations obs join cards c on obs.card_id = c.id where observations.species_id = obs.species_id and '#{self.observ_date}' > c.observ_date"
    @new_species_ids ||= self.observations.
        where("NOT EXISTS(#{subquery})").
        pluck(:species_id)
  end

end
