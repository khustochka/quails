class Image < ActiveRecord::Base
  has_and_belongs_to_many :observations, :include => [:species, :post]

  # Parameters

  def to_param
    code
  end

  # Associations

  def species
    observations.map(&:species).flatten
  end

  def post
    observations.map(&:post).uniq.compact.first
  end

  # Instance methods

  def to_url_params
    {:id => code, :species => species.first.to_param}
  end
end
