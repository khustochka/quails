class Image < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true, :length => { :maximum => 64 }

  before_save :observations_provided?

  has_and_belongs_to_many :observations, :include => [:species, :post]

  # Parameters

  def to_param
    code_was
  end

  # Associations

  def species
    observations.map(&:species).flatten
  end

  def post
    observations.map(&:post).uniq.compact.first
  end

  def observ_date
    observations.first.observ_date
  end

  # Instance methods

  def to_url_params
    {:id => code, :species => species.first.to_param}
  end

  def search_applicable_observations
    Observation.search(observations.present? && {:observ_date_eq => observations.first.observ_date, :locus_id_eq => observations.first.locus.id})
  end

  private
  def observations_provided?
    if observation_ids.empty?
      errors.add(:base, 'provide at least one observation')
      false
    end
  end
end
