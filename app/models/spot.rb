class Spot < ActiveRecord::Base
  belongs_to :observation
  has_many :images

  validates :observation_id, :lat, :lng, :zoom, :exactness, :public, presence: true

  scope :public, where(:public => true)
end
