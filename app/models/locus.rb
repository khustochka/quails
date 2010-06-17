class Locus < ActiveRecord::Base

  validates :code, :format => /^[a-z_]+$/i

  belongs_to :parent, :class_name => 'Locus'

  def to_param
    code
  end

end
