class Image < ActiveRecord::Base
  include FormattedModel

  invalidates CacheKey.gallery

  NORMAL_PARAMS = [:slug, :title, :description, :index_num, :has_old_thumbnail, :status]

  STATES = %w(DEFLT NOIDX)

  validates :slug, uniqueness: true, presence: true, length: {:maximum => 64}
  validates :flickr_id, uniqueness: true, allow_nil: true, exclusion: {in: ['']}

  has_and_belongs_to_many :observations
  has_many :species, :through => :observations

  # TODO: try to make it 'card', because image should belong to observations of the same card
  has_many :cards, :through => :observations

  has_many :spots, :through => :observations
  belongs_to :spot

  has_many :children, -> { basic_order }, class_name: 'Image', foreign_key: 'parent_id'

  serialize :assets_cache, ImageAssetsArray

  # Callbacks
  after_create do
    species.each(&:update_image)
  end

  after_save do
    cards.each { |c| c.post.try(:touch) }
    observations.each { |o| o.post.try(:touch) }
  end

  after_destroy do
    species.each(&:update_image)
    cards.each { |c| c.post.try(:touch) }
    observations.each { |o| o.post.try(:touch) }
  end

  def destroy
    # If associations are not cached before, they are empty on destroy, so have to preload them for after_destroy hook
    observations.to_a
    cards.to_a
    species.to_a
    super
  end

  # Scopes

  scope :indexable, lambda { where("status <> 'NOIDX'").top_level }

  scope :top_level, -> { where(parent_id: nil) }

  scope :basic_order, -> { order(:index_num, 'images.created_at', 'images.id') }

  # Parameters

  def to_param
    slug_was
  end

  # Photos with several species
  def self.multiple_species
    rel = select(:image_id).from("images_observations").group(:image_id).having("COUNT(observation_id) > 1")
    select("DISTINCT images.*, observ_date").where(id: rel).
        joins(:observations, :cards).preload(:species).order('observ_date ASC')
  end

  # Mapped photos
  def self.for_the_map
    Image.connection.select_rows(
        Image.select("spots.lat, spots.lng, loci.lat, loci.lon, images.id").
            joins(:cards => :locus).
            joins("LEFT OUTER JOIN (#{Spot.public.to_sql}) as spots ON spots.id=images.spot_id").
            where("spots.lat IS NOT NULL OR loci.lat IS NOT NULL").
            uniq.
            to_sql
    ).each_with_object({}) do |(lat1, lon1, lat2, lon2, im_id), memo|
      key = [(lat1 || lat2), (lon1 || lon2)].map { |x| (x.to_f * 100000).round / 100000.0 }
      (memo[key.join(',')] ||= []).push(im_id.to_i)
    end
  end

  def self.half_mapped
    Image.preload(:species).joins(:observations).
        where(spot_id: nil).where("observation_id in (select observation_id from spots)").
        order('created_at ASC')
  end

  # Associations

  # FIXME: think how to do this in a more clever way (posts?)
  def post(posts_source)
    posts_source.find_by_id(first_observation.post_id || cards.first.post_id)
  end

  delegate :observ_date, :locus, :locus_id, :to => :card

  def card
    first_observation.card
  end

  # Instance methods

  def on_flickr?
    flickr_id.present?
  end

  def multi?
    species.count > 1
  end

  ORDERING_COLUMNS = %w(cards.observ_date cards.locus_id index_num images.created_at images.id)
  PREV_NEXT_ORDER = "(ORDER BY #{ORDERING_COLUMNS.join(', ')})"

  def self.order_for_species
    self.joins("INNER JOIN cards ON observations.card_id = cards.id").order(*ORDERING_COLUMNS)
  end

  def prev_by_species(sp)
    sql = prev_next_sql(sp, "lag", self.parent_id.nil?)
    im = Image.from("(#{sql}) AS tmp").select("desired").where("img_id = ?", self.id)
    Image.where(id: im).first
  end

  def next_by_species(sp)
    sql = prev_next_sql(sp, "lead", self.parent_id.nil?)
    im = Image.from("(#{sql}) AS tmp").select("desired").where("img_id = ?", self.id)
    Image.where(id: im).first
  end

  def public_title
    title.present? ? title : species[0].name # Not using || because of empty string possibility
  end

  def search_applicable_observations
    ObservationSearch.new(
        new_record? ?
            {observ_date: Card.pluck('MAX(observ_date)').first} :
            {observ_date: observ_date, locus_id: locus.id}
    )
  end

  # TODO: Will deprecate
  def set_flickr_data(flickr, new_flickr_id)
    # if new flickr_id is nil or blank - assign nil
    self.flickr_id = new_flickr_id
    if self.flickr_id.blank?
      self.flickr_id = nil
    end
    if self.flickr_id_changed?
      self.assets_cache.swipe(:flickr)
      if self.flickr_id
        sizes_array = flickr.photos.getSizes(photo_id: flickr_id)

        self.assets_cache.swipe(:flickr)
        sizes_array.each do |fp|
          self.assets_cache << ImageAssetItem.new(:flickr, fp["width"].to_i, fp["height"].to_i, fp["source"])
        end
      end
    end
  end

  # Saving with observation validation

  def observations=(obs)
    update_with_observations({}, obs.map(&:id))
  end

  #def observation_ids=(*args)
  #  raise("Use update_with_observations!")
  #end

  def update_with_observations(attr, obs_ids)
    obs_ids.map!(&:to_i) if obs_ids
    assign_attributes(attr)
    validate_observations(obs_ids)
    if errors.any?
      run_validations!
      return false
    end
    with_transaction_returning_status do
      if self.spot_id && !self.spot.observation_id.in?(obs_ids)
        self.spot_id = nil
      end
      unless new_record?
        old_observations = self.observations.to_a
        old_species = self.species.to_a
      end
      self.observation_ids = obs_ids.uniq
      run_validations! && save.tap do |result|
        if result && old_species && old_observations
          old_species.each(&:update_image)
          old_observations.each { |o| o.post.try(:touch) }
        end
      end
    end
  end

  # Formatting

  def to_thumbnail
    title = self.formatted.title
    child_num = children.count
    if child_num > 0
      title = "#{title} (#{child_num + 1} фото)"
    end
    Thumbnail.new(self, title, self, {image: {id: id}})
  end

  def mapped?
    spot_id
  end

  private

  def first_observation
    observations[0]
  end

  def validate_observations(observ_ids)
    obs = Observation.where(id: observ_ids)
    if obs.blank?
      errors.add(:observations, 'must not be empty')
    else
      if obs.map(&:card_id).uniq.size > 1
        errors.add(:observations, 'must belong to the same card')
      end
    end
  end

  def prev_next_sql(sp, lag_or_lead, only_top_level)
    Image.connection.unprepared_statement do
      sp.ordered_images.
          select("images.id AS img_id, #{lag_or_lead}(images.id) OVER #{PREV_NEXT_ORDER} AS desired").
          where(only_top_level ? "parent_id IS NULL" : nil).
          except(:order).
          to_sql
    end
  end

end
