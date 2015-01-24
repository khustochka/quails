class Book < ActiveRecord::Base

  has_many :taxa, -> {order "taxa.index_num"}, dependent: :restrict_with_exception

  # Parameters

  def to_param
    slug_was
  end

end
