class Card < ActiveRecord::Base
  has_many :observations
  belongs_to :locus
  belongs_to :post

  validates :locus_id, :observ_date, presence: true

  accepts_nested_attributes_for :observations,
                                reject_if: proc { |attrs| attrs.all? { |k, v| v.blank? || k == 'voice' } }

end
