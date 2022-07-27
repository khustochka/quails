# frozen_string_literal: true

class IocTaxon < ApplicationRecord
  SPECIES_RANK = -"Species"
  SUBSPECIES_RANK = -"ssp"

  acts_as_list column: :index_num

  belongs_to :ioc_species, class_name: "IocTaxon", optional: true
  has_many :ioc_subspecies, class_name: "IocTaxon", foreign_key: :ioc_species_id, dependent: :restrict_with_exception, inverse_of: :ioc_species

  scope :species, -> { where(rank: SPECIES_RANK) }
  scope :subspecies, -> { where(rank: SUBSPECIES_RANK) }

  def species?
    rank == SPECIES_RANK
  end

  def subspecies?
    rank == SUBSPECIES_RANK
  end

  def fallback_species
    species? ? self : ioc_species
  end
end
