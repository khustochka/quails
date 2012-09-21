class Authority < ActiveRecord::Base

  has_many :book_species, order: :index_num

  # Parameters

  def to_param
    slug_was
  end

end
