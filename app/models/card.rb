class Card < ActiveRecord::Base
  has_many :observations
  belongs_to :locus
  belongs_to :post
end
