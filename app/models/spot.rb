class Spot < ActiveRecord::Base
  belongs_to :observation
  has_many :images
end
