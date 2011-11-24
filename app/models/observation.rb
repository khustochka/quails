class Observation < ActiveRecord::Base
  belongs_to :species
  belongs_to :locus
  belongs_to :post, :select => [:id, :code, :face_date, :title, :status]
  has_and_belongs_to_many :images

  attr_accessor :one_of_bulk

  before_destroy do
    if images.present?
      raise ActiveRecord::DeleteRestrictionError.new(self.class.reflections[:images])
    end
  end

  after_save :unless => :one_of_bulk do
    Observation.biotopes(true) # refresh the cached biotopes list
  end

  validates :observ_date, :locus_id, :species_id, :presence => true

  # Scopes

  scope :mine, where(:mine => true)

  scope :identified, where('observations.species_id != 0')

  # Get data

  def self.biotopes(refresh = false)
    if @biotopes && !refresh
      @biotopes
    else
      @biotopes = select("DISTINCT biotope").map(&:biotope)
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