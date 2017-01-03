class Spot < ApplicationRecord

  EXACTNESS = %w(precise exact rough)

  belongs_to :observation
  has_many :media, dependent: :nullify

  validates :observation_id, :lat, :lng, :zoom, :exactness, presence: true

  scope :public_spots, lambda { where(public: true) }
end
