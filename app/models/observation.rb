class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus

  validates :observ_date, :presence => true

  scope :mine, where(:mine => true)
  scope :species_first_met_dates, mine.select(:species_id, 'MIN(observ_date) AS mind').group(:species_id)

end
