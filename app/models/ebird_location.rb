class EbirdLocation < ApplicationRecord

  has_many :loci

  def to_label
    name
  end

end
