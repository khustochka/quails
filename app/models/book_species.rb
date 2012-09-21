class BookSpecies < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  validates :order, :presence => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true

  # Associations

  belongs_to :authority
  belongs_to :species

  # Parameters

  def to_param
    name_sci_was.sp_parameterize
  end

end
