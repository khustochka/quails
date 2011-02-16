class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus
  belongs_to :post

  validates :observ_date, :presence => true

  # Scopes

  scope :mine, where('mine = TRUE')

  scope :identified, where('species_id IS NOT NULL')

  def self.years(*args)
    options = args.extract_options!
    rel     = mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  def self.first_met_observations(*args)
    options = args.extract_options!
    rel2 = mine.identified.select('id').from('observations AS ob2').order('observ_date').limit(1)
    rel2 = rel2.where('species_id = observations.species_id')
    rel2 = rel2.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel2 = rel2.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel2 = rel2.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?

    where("observations.id = (#{rel2.to_sql})")
  end

  def self.lifelist(*args)
    first_met_observations(*args).includes(:species, :post).order('observ_date DESC')
  end

end
