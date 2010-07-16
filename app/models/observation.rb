class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus

  validates :observ_date, :presence => true

  scope :mine, where(:mine => true)
  scope :species_first_met_dates, lambda {|*args|
    options = args.extract_options!
    rel = mine.select(:species_id, 'MIN(observ_date) AS mind').group(:species_id)
    rel = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].nil?
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].nil?
    rel = rel.joins(:locus).where('locus.code' => options[:locus]) unless options[:locus].nil?
    rel
  }

  scope :years, lambda {|*args|
    options = args.extract_options!
    rel = mine.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].nil?
    rel = rel.joins(:locus).where('locus.code' => options[:locus]) unless options[:locus].nil?
    rel
  }

end
