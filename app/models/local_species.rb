class LocalSpecies < ActiveRecord::Base
  delegate :order, :family, :name, :name_sci, :to_param, to: :species

  belongs_to :locus
  belongs_to :species
  has_one :image, through: :species
end
