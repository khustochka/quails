class Image < ActiveRecord::Base
  has_and_belongs_to_many :observations

  # Parameters

  def to_param
    code
  end
end
