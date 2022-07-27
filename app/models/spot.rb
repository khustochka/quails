# frozen_string_literal: true

class Spot < ApplicationRecord
  EXACTNESS = %w(precise exact rough)

  belongs_to :observation
  has_many :media, dependent: :nullify
  has_many :cards, through: :observations, inverse_of: :spots

  validates :lat, :lng, :zoom, :exactness, presence: true

  scope :public_spots, lambda { where(public: true) }
end
