class Book < ActiveRecord::Base

  has_many :taxa, order: :index_num

  # Parameters

  def to_param
    slug_was
  end

end
