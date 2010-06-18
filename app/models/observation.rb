class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus

  validates :observ_date, :presence => true

end
