class EbirdTaxon < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  acts_as_ordered :index_num

  # validates :order, :presence => true
  # validates :family, :presence => true
  # validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => {scope: :book_id}
  # validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true
  # validates :species_id, uniqueness: {scope: :book_id}, :allow_blank => true

  # Associations

  belongs_to :species
  belongs_to :parent, class_name: "EbirdTaxon"

  # Parameters

  # temporarily using ebird code
  def to_param
    ebird_code
  end

end
