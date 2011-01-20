class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus
  belongs_to :post

  validates :observ_date, :presence => true

  # Scopes

  scope :mine, where(:mine => true)

  scope :identified, where('species_id IS NOT NULL')

  def self.years(*args)
    options = args.extract_options!
    rel     = mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel     = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel     = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  # Not used
  def self.species_first_met_dates(*args)
    options = args.extract_options!
    rel     = mine.identified.select('species_id, MIN(observ_date) AS mind').group(:species_id)
    rel     = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel     = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel     = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    rel
  end

end
