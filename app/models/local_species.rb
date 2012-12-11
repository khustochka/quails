class LocalSpecies < ActiveRecord::Base

  has_many :taxa, foreign_key: :species_id, primary_key: :species_id

  delegate :order, :family, to: :taxon

  #belongs_to :locus
  #belongs_to :species
  #has_one :image, through: :species

  def taxon
    raise "Local species taxa not loaded" unless association(:taxa).loaded?
    raise "Local species taxa not filtered by checklist" if taxa.size > 1
    taxa.first
  end

end
