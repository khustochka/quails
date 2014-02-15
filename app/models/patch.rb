class Patch < ActiveRecord::Base

  def to_param
    name_was
  end
end
