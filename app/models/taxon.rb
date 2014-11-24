require 'species_parameterizer'

class Taxon < ActiveRecord::Base

  invalidates CacheKey.gallery
  invalidates CacheKey.checklist

  extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  validates :order, :presence => true
  validates :family, :presence => true
  validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => {scope: :book_id}
  validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true
  validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  acts_as_ordered :index_num, scope: :book_id

  # Associations

  belongs_to :book
  belongs_to :species
  has_one :image, through: :species

  # Parameters

  def to_param
    Taxon.parameterize(name_sci_was)
  end

end
