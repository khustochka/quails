class Locus < ActiveRecord::Base

  validates :code, :format => /^[a-z_]+$/

  def to_param
    code
  end

end
