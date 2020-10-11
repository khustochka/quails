# frozen_string_literal: true

require 'species_parameterizer'

class LegacySpecies < ApplicationRecord

  extend SpeciesParameterizer

  localized_attr :name

  serialize :wikidata, Hash

#  validates :order, presence: true, allow_blank: true
  validates :family, presence: true
  validates :name_sci, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/, uniqueness: true
  validates :code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true
  validates :avibase_id, format: /\A[\dA-F]{16}\Z/, allow_blank: true
  validates :index_num, presence: true

  acts_as_list column: :index_num

  belongs_to :species

  AVIS_INCOGNITA = Struct.new(:id, :name_sci, :to_label, :name).
      new(0, '- Avis incognita', '- Avis incognita', '- Avis incognita')

  # Parameters

  def to_param
    LegacySpecies.parameterize(name_sci_was)
  end

  def to_label
    name_sci
  end

  def code=(val)
    super(val == '' ? nil : val)
  end

  # Scopes

  scope :short, lambda { select("legacy_species.id, name_sci, name_en, name_ru, name_uk, legacy_species.index_num") }

  scope :ordered_by_taxonomy, lambda { distinct.reorder("legacy_species.index_num") }

  scope :alphabetic, lambda { order(:name_sci) }

  # Wikidata

  def wikidata
    Hashie::Mash.new(read_attribute('wikidata'))
  end

end
