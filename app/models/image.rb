class Image < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true, :length => {:maximum => 64}

  has_and_belongs_to_many :observations, :include => :species, :uniq => true
  has_many :species, :through => :observations

  delegate :observ_date, :post, :locus, :to => :first_observation

  # Parameters

  def to_param
    code_was
  end

  # Instance methods

  def to_url_params
    {:id => code, :species => (species.first.to_param || 'Avis_incognita')}
  end

  def search_applicable_observations
    Observation.search(
        new_record? ?
            {:observ_date_eq => Observation.select('MAX(observ_date) AS last_date').first.last_date} :
            {:observ_date_eq => observ_date, :locus_id_eq => locus.id}
    )
  end

  delegate :observ_date, :locus, :to => :first_observation

  # Saving with observation validation

  def update_with_observations(attr)
    obs_ids = attr.delete(:observation_ids)
    validate_observations(obs_ids)
    with_transaction_returning_status do
      assign_attributes(attr)
      self.observation_ids = obs_ids unless obs_ids.blank?
      run_validations! && save
    end
  end

  private

  def first_observation
    observations[0]
  end

  def validate_observations(observ_ids)
    if observ_ids.blank?
      errors.add(:observation_ids, 'must not be empty')
    else
      obs = Observation.where(:id => observ_ids).all
      if obs.map(&:observ_date).uniq.size > 1 || obs.map(&:locus_id).uniq.size > 1
        errors.add(:observation_ids, 'must be of the same date and location')
      end
    end
  end

end
