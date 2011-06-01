class Image < ActiveRecord::Base
  has_and_belongs_to_many :observations #, :include => :species # works but I don't need it always

  # Parameters

  def to_param
    code
  end

  # Associations

  def species
    #TODO: force eager loading # seems include not working here
    observations(:include => :species).map(&:species).flatten
  end
end
