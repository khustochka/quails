class Spot < ActiveRecord::Base

  EXACTNESS = %w(precise exact rough)

  belongs_to :observation
  has_many :images

  validates :observation_id, :lat, :lng, :zoom, :exactness, presence: true

  scope :public, lambda { where(:public => true) }
end
