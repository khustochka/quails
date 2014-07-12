class Image < ActiveRecord::Base
  include FormattedModel
  include Observationable

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
    cards.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
    observations.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
  end

  after_destroy do
    species.each(&:update_image)
    cards.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
    observations.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
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
        Image.for_the_map_query.to_sql
    ).each_with_object({}) do |(im_id, lat1, lon1, lat2, lon2), memo|
      key = [(lat1 || lat2), (lon1 || lon2)].map { |x| (x.to_f * 100000).round / 100000.0 }
      (memo[key.join(',')] ||= []).push(im_id.to_i)
    end
  end

  def self.half_mapped
    Image.preload(:species).joins(:observations).
        where(spot_id: nil).where("observation_id in (select observation_id from spots)").
        order(created_at: :asc)
  end

  # Associations

  def posts
    posts_id = [first_observation.post_id, cards.first.post_id].uniq.compact
    Post.where(id: posts_id)
  end

  # Instance methods

  def on_flickr?
    flickr_id.present?
  end

  def multi?
    species.count > 1
  end

  ORDERING_COLUMNS = %w(cards.observ_date cards.locus_id index_num images.created_at images.id)
  PREV_NEXT_ORDER = "ORDER BY #{ORDERING_COLUMNS.join(', ')}"

  def self.order_for_species
    self.joins("INNER JOIN cards ON observations.card_id = cards.id").order(*ORDERING_COLUMNS)
  end

  def prev_by_species(sp)
    prev_next_by(sp)[-1]
  end

  def next_by_species(sp)
    prev_next_by(sp)[1]
  end

  def public_title
    if I18n.russian_locale? && title.present?
      title
    else
      species.map(&:name).join(', ')
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
    child_num = children.size
    if child_num > 0
      title = "#{title} (#{child_num + 1} #{I18n.t('images.series_photos_num')})"
    end
    Thumbnail.new(self, title, self, {image: {id: id}})
  end

  def mapped?
    spot_id
  end

  def public_locus
    locus.public_locus
  end

  private

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

  def prev_next_by(sp)
    @prev_next ||= {}
    if @prev_next[sp]
      return @prev_next[sp]
    end
    # Calculate row number for every image under partition
    window =
        Image.select("images.*, row_number() over (partition by species_id #{PREV_NEXT_ORDER}) as rn").
            joins(:cards).
            where("observations.species_id" => sp.id)
    # Join ranked tables by neighbouring images
    # Select neighbours of the sought one, exclude duplication
    q = "with ranked as (#{window.to_sql})
      select that.*, that.rn - this.rn as diff
      from ranked that
      join ranked this on that.rn between this.rn-1 and this.rn+1
      where this.id='#{self.id}' and this.rn <> that.rn"
    @prev_next[sp] = Image.find_by_sql(q).index_by(&:diff)
  end

  def self.for_the_map_query
    Image.select("images.id,
                  COALESCE(spots.lat, patches.lat, public_locus.lat, parent_locus.lat) AS lat,
                  COALESCE(spots.lng, patches.lon, public_locus.lon, parent_locus.lon) AS lng").
        joins(:cards).
        joins("LEFT OUTER JOIN (#{Spot.public_spots.to_sql}) as spots ON spots.id=images.spot_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as patches ON patches.id=observations.patch_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as public_locus ON public_locus.id=cards.locus_id").
        joins("JOIN loci as card_locus ON card_locus.id=cards.locus_id").
        joins("LEFT OUTER JOIN (#{Locus.non_private.to_sql}) as parent_locus ON card_locus.ancestry LIKE CONCAT(parent_locus.ancestry, '/', parent_locus.id)").
        where("spots.lat IS NOT NULL OR patches.lat IS NOT NULL OR public_locus.lat IS NOT NULL OR parent_locus.lat IS NOT NULL").
        uniq
  end

end
