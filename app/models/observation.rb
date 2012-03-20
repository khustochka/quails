class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus
  belongs_to :post, :select => [:id, :code, :face_date, :title, :status]
  has_and_belongs_to_many :images
  has_many :spots

  attr_accessor :one_of_bulk

  DEFAULT_BIOTOPES = %w(open building garden water park bush woods)

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  after_save :unless => :one_of_bulk do
    Observation.biotopes(true) # refresh the cached biotopes list
  end

  validates :observ_date, :locus_id, :species_id, :biotope, :presence => true

  # Scopes

  scope :mine, where(:mine => true)

  scope :identified, where('observations.species_id != 0')

  # TODO: improve and probably use universally
  def self.filter(options = {})
    rel = Observation.mine.identified
    rel = rel.where('EXTRACT(year from observ_date) = ?', options[:year]) unless options[:year].blank?
    rel = rel.where('EXTRACT(month from observ_date) = ?', options[:month]) unless options[:month].blank?
    rel = rel.where('species_id' => options[:species]) unless options[:species].blank?
    rel = rel.where('locus_id' => options[:locus]) unless options[:locus].blank?
    rel
  end

  # Get data

  def self.biotopes(refresh = false)
    if @biotopes && !refresh
      @biotopes
    else
      @biotopes = (DEFAULT_BIOTOPES + uniq.pluck(:biotope)).uniq
    end
  end

  # Species

  alias_method :real_species, :species

  def species
    species_id == 0 ?
        Species::AVIS_INCOGNITA :
        real_species
  end

  # Decorators

  def species_str
    [["<b>#{species.name}</b>", species.name_sci].join(' '), quantity, notes].
        delete_if(&:'blank?').join(', ').html_safe
  end

  def when_where_str
    [observ_date, "<b>#{locus.name_en}</b>", place].delete_if(&:'blank?').join(', ').html_safe
  end

end