class Image < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true, :length => { :maximum => 64 }

  before_save :observations_provided?

  has_and_belongs_to_many :observations, :include => [:species, :post]
  has_many :species, :through => :observations

  delegate :observ_date, :post, :locus, :to => :first_observation

  # Parameters

  def to_param
    code_was
  end

  # Instance methods

  def to_url_params
    {:id => code, :species => species.first.to_param}
  end

  def search_applicable_observations
    Observation.search(observations.present? && {:observ_date_eq => first_observation.observ_date, :locus_id_eq => first_observation.locus.id})
  end

  private
  def observations_provided?
    if observation_ids.empty?
      errors.add(:base, 'provide at least one observation')
      false
    end
  end

  def first_observation
    observations[0]
  end

end
