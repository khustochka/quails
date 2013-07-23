class Card < ActiveRecord::Base
  include FormattedModel

  invalidates CacheKey.lifelist

  belongs_to :locus
  belongs_to :post, touch: :updated_at
  has_many :observations, dependent: :restrict_with_exception
  has_many :images, through: :observations
  has_many :species, through: :observations
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

end
