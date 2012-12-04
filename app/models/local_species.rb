class LocalSpecies < ActiveRecord::Base
  include ActiveRecord::Localized
  localize :name

  belongs_to :locus
  belongs_to :species
  has_one :image, through: :species

  def to_param
    name_sci.sp_parameterize
  end
end
