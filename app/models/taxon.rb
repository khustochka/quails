#require 'species_parameterizer'

class Taxon < ApplicationRecord

  # invalidates CacheKey.gallery
  # invalidates CacheKey.checklist

  # extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  acts_as_ordered :index_num

  # validates :order, :presence => true
  # validates :family, :presence => true
  # validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => {scope: :book_id}
  # validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true
  # validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  # Associations
  belongs_to :parent, class_name: "Taxon"
  has_many :children, class_name: "Taxon", foreign_key: "parent_id", dependent: :restrict_with_exception
  belongs_to :species
  belongs_to :ebird_taxon

  has_many :observations, dependent: :restrict_with_exception
  has_many :images, through: :observations

  scope :category_species, -> { where(category: "species") }

  def self.weighted_by_abundance
    obs = Observation.select("taxon_id, COUNT(observations.id) as weight").group(:taxon_id)
    self.joins("LEFT OUTER JOIN (#{obs.to_sql}) obs on id = obs.taxon_id")
  end

  # Parameters

  def to_param
    ebird_code
  end

  def to_label
    [name_sci, name_en].join(" - ")
  end

  def countable?
    species_id.present?
  end

  def is_a_species?
    category == "species"
  end

end
