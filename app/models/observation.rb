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

  scope :identified, where('observations.species_id != 9999')

  def self.years(*args)
    options = args.extract_options!
    rel = mine.identified.select('DISTINCT EXTRACT(year from observ_date) AS year').order(:year)
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('locus_id' => options[:loc_ids]) unless options[:locus].blank?
    [nil] + rel.map { |ob| ob[:year] }
  end

  def self.lifelist(*args)
      find_by_sql("
          SELECT obs.species_id, aggr_value, name_sci, name_en, name_ru, name_uk, p.code, face_date
          FROM observations AS obs
            JOIN (
              SELECT species_id, MIN(observ_date) as aggr_value
              FROM observations
              WHERE mine = true AND species_id != 9999
              GROUP BY species_id
            ) AS mins
            ON (obs.species_id = mins.species_id AND obs.observ_date = mins.aggr_value)
            JOIN species ON (mins.species_id = species.id)
            LEFT JOIN (SELECT * FROM posts WHERE status = 'OPEN') AS p ON (obs.post_id = p.id)
          WHERE mine = true
          ORDER BY observ_date DESC
          "
      ).group_by(&:species_id).map { |_, v| v.first }
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

end