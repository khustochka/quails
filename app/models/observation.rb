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

  # Species

  alias_method :real_species, :species

  def species
    species_id == 0 ?
        Species::AVIS_INCOGNITA :
        real_species
  end

  # Decorators
  
  def obs_species_data
    [["<b>#{species.name}</b>", species.name_sci].join(' '), quantity, notes].
        delete_if(&:'blank?').join(', ').html_safe
  end
  
  def obs_when_where_data
    [observ_date, "<b>#{locus.name_en}</b>", place].delete_if(&:'blank?').join(', ').html_safe
  end

end