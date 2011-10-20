class Image < ActiveRecord::Base
  validates :code, :uniqueness => true, :presence => true, :length => {:maximum => 64}
  validates :observation_ids, :presence => true

  has_and_belongs_to_many :observations, :include => [:species, :post]
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
            {:observ_date_eq => Date.yesterday} :
            {:observ_date_eq => observ_date, :locus_id_eq => locus.id}
    )
  end

  delegate :observ_date, :locus, :to => :first_observation

  private

  def first_observation
    observations[0]
  end

end
