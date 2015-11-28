class Media < ActiveRecord::Base
  has_and_belongs_to_many :observations

  serialize :assets_cache, ImageAssetsArray

  has_many :taxa, through: :observations
  has_many :species, through: :taxa

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

  # Mapped photos and vidoes
  def self.for_the_map
    Media.connection.select_rows(
        Media.for_the_map_query.to_sql
    ).each_with_object({}) do |(im_id, lat, lon), memo|
      key = [lat, lon].map { |x| (x.to_f * 100000).round / 100000.0 }
      (memo[key.join(',')] ||= []).push(im_id.to_i)
    end
  end

  def self.half_mapped
    Media.preload(:species).joins(:observations).
        where(spot_id: nil).where("observation_id in (select observation_id from spots)").
        order(created_at: :asc)
  end

  def extend_with_class
    self.becomes(AVAILABLE_CLASSES[media_type].constantize)
  end

  def to_thumbnail
    extend_with_class.to_thumbnail
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

  def species
    taxa.map(&:species).uniq
  end

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

  def self.for_the_map_query
    Media.select("media.id,
                  COALESCE(spots.lat, patches.lat, public_locus.lat, parent_locus.lat) AS lat,
                  COALESCE(spots.lng, patches.lon, public_locus.lon, parent_locus.lon) AS lng").
        joins(:cards).
        joins("LEFT OUTER JOIN (#{Spot.public_spots.to_sql}) as spots ON spots.id=media.spot_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as patches ON patches.id=observations.patch_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as public_locus ON public_locus.id=cards.locus_id").
        joins("JOIN loci as card_locus ON card_locus.id=cards.locus_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as parent_locus ON card_locus.ancestry LIKE CONCAT(parent_locus.ancestry, '/', parent_locus.id)").
        where("spots.lat IS NOT NULL OR patches.lat IS NOT NULL OR public_locus.lat IS NOT NULL OR parent_locus.lat IS NOT NULL").
        uniq
  end

end
