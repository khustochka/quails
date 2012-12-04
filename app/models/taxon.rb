class Taxon < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  validates :order, :presence => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => {scope: :book_id}
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true
  validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  # Associations

  belongs_to :book
  belongs_to :species
  has_one :image, through: :species

  # Parameters

  def to_param
    name_sci_was.sp_parameterize
  end

end
