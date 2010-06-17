class Locus < ActiveRecord::Base

  validates :code, :format => /^[a-z_]+$/

  belongs_to :parent, :class => Locus

  def to_param
    code
  end

end
