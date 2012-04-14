class Image < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true, :length => {:maximum => 64}

  has_and_belongs_to_many :observations, :include => :species
  has_many :species, :through => :observations
  belongs_to :spot

  delegate :observ_date, :locus, :to => :first_observation

  serialize :flickr_data

  # Parameters

  def to_param
    code_was
  end

  # Associations

  def post(posts_source)
    posts_source.find_by_id(first_observation.post_id)
  end

  # Instance methods

  def public_title
    title.present? ? title : species[0].name # Not using || because of empty string possibility
  end

  def species_for_url
    case species.size
      when 0
        'Avis_incognita'
      when 1
        species.first.to_param
      else
        'Aves_sp'
    end
  end

  def to_url_params
    {id: code, species: species_for_url}
  end

  def search_applicable_observations
    Observation.search(
        new_record? ?
            {:observ_date_eq => Observation.select('MAX(observ_date) AS last_date').first.last_date} :
            {:observ_date_eq => observ_date, :locus_id_eq => locus.id}
    )
  end

  # Saving with observation validation

  def update_with_observations(attr, obs_ids)
    validate_observations(obs_ids)
    with_transaction_returning_status do
      assign_attributes(attr)
      self.observation_ids = obs_ids.uniq unless obs_ids.blank?
      run_validations! && save
    end
  end

  private

  def first_observation
    observations[0]
  end

  def validate_observations(observ_ids)
    if observ_ids.blank?
      errors.add(:observations, 'must not be empty')
    else
      obs = Observation.where(:id => observ_ids).all
      if obs.map(&:observ_date).uniq.size > 1 || obs.map(&:locus_id).uniq.size > 1 || obs.map(&:mine).uniq.size > 1
        errors.add(:observations, 'must have the same date, location, and mine value')
      end
    end
  end

end
