class Card < ActiveRecord::Base

  include FormattedModel

  belongs_to :locus
  belongs_to :post
  has_many :observations, dependent: :restrict
  has_many :images, through: :observations
  has_many :species, through: :observations

  validates :locus_id, :observ_date, presence: true

  accepts_nested_attributes_for :observations,
                                reject_if:
                                    proc { |attrs| attrs.all? { |k, v| v.blank? || k == 'voice' || k == 'mine' } }

end
