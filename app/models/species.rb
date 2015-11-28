require 'species_parameterizer'

class Species < ActiveRecord::Base

  extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  validates :order, presence: true
  validates :family, presence: true
  validates :name_sci, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/, uniqueness: true
  validates :code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true
  #validates :avibase_id, format: /\A[\dA-F]{16}\Z/, allow_blank: true
  validates :index_num, presence: true

  acts_as_ordered :index_num

  # Parameters

  def to_param
    Species.parameterize(name_sci_was)
  end

  def to_label
    name_sci
  end

end
