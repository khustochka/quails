class Authority < ActiveRecord::Base

  # Parameters

  def to_param
    slug_was
  end

end
