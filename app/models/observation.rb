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
    rel = mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  def self.lifers_dates(*args)
    options = args.extract_options!
    rel = mine.identified.select('species_id, MIN(observ_date) AS first_date').group(:species_id)
    rel = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    rel
  end

  def self.lifers_observations(*args)
    options = args.extract_options!

    # Using join on earliest date is the fastest
    select('DISTINCT ON (observations.species_id, observ_date) observations.*').\
        joins("INNER JOIN (#{lifers_dates(options).to_sql}) AS dts
          ON observations.species_id=dts.species_id AND observations.observ_date=dts.first_date")
  end

  def self.lifelist(*args)
    # have to exclude duplicates explicitly because Arel fails to build complex query
    list = lifers_observations(*args).includes(:species, :post).order('observations.observ_date DESC').all
    list.inject([]) { |memo, el| el.species_id == memo[-1].try(:species_id) ? memo : memo.push(el) }
  end

end