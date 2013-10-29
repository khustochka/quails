class Card < ActiveRecord::Base
  include FormattedModel

  invalidates CacheKey.lifelist

  belongs_to :locus
  belongs_to :post, touch: :updated_at
  has_many :observations, -> { order('observations.id') }, dependent: :restrict_with_exception
  has_many :images, through: :observations
  has_many :species, -> { order(:index_num) }, through: :observations
  has_many :spots, through: :observations

  validates :locus_id, :observ_date, presence: true

  accepts_nested_attributes_for :observations,
                                reject_if:
                                    proc { |attrs| attrs.all? { |k, v| v.blank? || k == 'voice' } }

  def secondary_posts
    Post.uniq.joins(:observations).where('observations.card_id =? AND observations.post_id <> ?', self.id, self.post_id)
  end

  def mapped?
    spots.any?
  end

  # List of new species
  def new_species_ids
    subquery = "select obs.id from observations obs join cards c on obs.card_id = c.id where observations.species_id = obs.species_id and '#{self.observ_date}' > c.observ_date"
    @new_species_ids ||= self.observations.
        where("NOT EXISTS(#{subquery})").
        pluck(:species_id)
  end

end
