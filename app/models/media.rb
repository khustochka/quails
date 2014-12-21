class Media < ActiveRecord::Base
  has_and_belongs_to_many :observations

  serialize :assets_cache, ImageAssetsArray

  has_many :species, through: :observations

  # TODO: try to make it 'card', because image should belong to observations of the same card
  has_many :cards, through: :observations

  has_many :spots, through: :observations
  belongs_to :spot

  validate :consistent_observations

  validates :slug, uniqueness: true, presence: true, length: {:maximum => 64}

  after_update :update_spot

  AVAILABLE_CLASSES = {
      'photo' => 'Image',
      'video' => 'Video'
  }

  # Needed for ome reason for becomes
  attr_accessor :type

  # Parameters

  def to_param
    slug_was
  end

  def observation_ids=(list)
    super(list.uniq)
  end

  def mapped?
    spot_id
  end

  def extend_with_class
    self.becomes(AVAILABLE_CLASSES[media_type].constantize)
  end

  def search_applicable_observations(params = {})
    date = params[:date]
    ObservationSearch.new(
        new_record? ?
            {observ_date: date || Card.pluck('MAX(observ_date)').first} :
            {observ_date: observ_date, locus_id: locus.id}
    )
  end

  delegate :observ_date, :locus, :locus_id, to: :card

  def card
    first_observation.card
  end

  def public_title
    if I18n.russian_locale? && title.present?
      title
    else
      species.map(&:name).join(', ')
    end
  end

  def public_locus
    locus.public_locus
  end

  def posts
    posts_id = [first_observation.post_id, cards.first.post_id].uniq.compact
    Post.where(id: posts_id)
  end

  private

  def consistent_observations
    obs = Observation.where(id: observation_ids)
    if obs.blank?
      errors.add(:observations, 'must not be empty')
    else
      if obs.map(&:card_id).uniq.size > 1
        errors.add(:observations, 'must belong to the same card')
      end
    end
  end

  def first_observation
    observations[0]
  end

  def update_spot
    if spot_id && !spot.observation_id.in?(observation_ids)
      self.update_column(:spot_id, nil)
    end
  end

end
