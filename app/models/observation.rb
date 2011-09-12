class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus
  belongs_to :post, :select => [:id, :code, :face_date, :title, :status]
  has_and_belongs_to_many :images

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  validates :observ_date, :locus_id, :species_id, :presence => true

  # Scopes

  scope :mine, where(:mine => true)

  scope :identified, where('observations.species_id != 0')

  def self.years(*args)
    options = args.extract_options!
    rel = mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  def self.old_lifers_dates(*args)
    options = args.extract_options!
    rel = mine.identified.select(
            <<SQL
        species_id AS main_species,
        MIN(observ_date) AS first_date,
        MAX(observ_date) AS last_date,
        COUNT(id) AS view_count
SQL
    ).group(:species_id)
    rel = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    rel
  end

  def self.old_lifers_observations(*args)
    select('dates.*, ob1.post_id AS first_post, ob2.post_id AS last_post').
            from("(#{old_lifers_dates(*args).to_sql}) AS dates").
            joins("INNER JOIN (#{Observation.mine.to_sql}) AS ob1 ON main_species=ob1.species_id AND first_date=ob1.observ_date").
            joins("INNER JOIN (#{Observation.mine.to_sql}) AS ob2 ON main_species=ob2.species_id AND last_date=ob2.observ_date")
  end

  # Species

  alias :real_species :species

  def species
    species_id == 0 ?
            Species::AVIS_INCOGNITA :
            real_species
  end

end