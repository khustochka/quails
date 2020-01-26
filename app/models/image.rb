class Image < Media
  include DecoratedModel

  invalidates CacheKey.gallery

  STATES = %w(PUBLIC NOINDEX POST_ONLY EBIRD_ONLY PRIVATE)

  has_many :children, -> { basic_order }, class_name: 'Image', foreign_key: 'parent_id'

  has_one_attached :stored_image

  validates :external_id, uniqueness: true, allow_nil: true, exclusion: {in: ['']}
  validates :status, inclusion: STATES, presence: true, length: {maximum: 16}

  validate :has_attached_image
  validate :stored_image_valid_content_type
  validate :blob_uniqueness

  default_scope -> { where(media_type: 'photo').with_attached_stored_image }

  scope :unflickred, -> { where(external_id: nil) }

  # Callbacks
  after_create do
    species.each(&:update_image)
  end

  # FIXME: the NEW post is touched if it exists, but not the OLD!
  after_save do
    cards.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
    observations.preload(:post).map(&:post).uniq.each { |p| p.try(:touch) }
  end

  before_destroy do
    # Save observation ids to make after_destroy work properly
    @cached_observation_ids = self.observation_ids
  end

  after_destroy do
    base_obs = Observation.where(id: @cached_observation_ids)
    species = Species.joins(:taxa).where(taxa: {id: base_obs.select(:taxon_id)})
    species.each(&:update_image)

    cards = Card.where(id: base_obs.select(:card_id)).preload(:post)
    cards.map(&:post).uniq.each { |p| p.try(:touch) }

    observations = base_obs.preload(:post)
    observations.map(&:post).uniq.each { |p| p.try(:touch) }
  end

  # Scopes

  scope :indexable, lambda { where("status <> 'NOINDEX'") }

  scope :basic_order, -> { order(:index_num, 'media.created_at', 'media.id') }

  # Photos with several species
  def self.multiple_species
    rel = select(:media_id).from("media_observations").group(:media_id).having("COUNT(observation_id) > 1")
    select("DISTINCT media.*, observ_date").where(id: rel).
        joins({:observations => :taxon}, :cards).preload(:species).order('observ_date ASC')
  end

  # Instance methods

  def flickr_id
    external_id
  end

  def flickr_id=(val)
    self.external_id = val
  end

  def on_flickr?
    flickr_id.present?
  end

  def on_storage?
    stored_image.attachment.present?
  end

  def multi?
    species.size > 1
  end

  #ORDERING_COLUMNS = %w(cards.observ_date cards.locus_id species.index_num media.created_at media.id)
  ORDERING_SINGLE_SPECIES = %w(cards.observ_date cards.locus_id media.created_at media.id)
  PREV_NEXT_ORDER = -"ORDER BY #{ORDERING_SINGLE_SPECIES.join(', ')}"

  def self.order_for_species
    self.joins("INNER JOIN cards ON observations.card_id = cards.id").order(*ORDERING_SINGLE_SPECIES)
  end

  def prev_by_species(sp)
    prev_next_by(sp)[-1]
  end

  def next_by_species(sp)
    prev_next_by(sp)[1]
  end

  # Formatting

  def to_thumbnail
    title = self.decorated.title
    Thumbnail.new(self, title, self, {image: {id: id}})
  end

  def stored_image_to_asset_item
    ImageAssetItem.new(
        :storage,
        stored_image.metadata[:width],
        stored_image.metadata[:height],
        stored_image_thumbnail_variant.url
    )
  end

  def stored_image_thumbnail_variant
    stored_image.variant(resize: "800x600>")
  end

  # FIXME: another duplication...
  def thumbnail_variant
    if on_storage?
      stored_image_thumbnail_variant
    elsif on_flickr?
      assets_cache.externals.thumbnail.full_url
    else
      assets_cache.locals.thumbnail.full_url
    end
  end

  private

  def prev_next_by(sp)
    @prev_next ||= {}
    if @prev_next[sp]
      return @prev_next[sp]
    end
    # Calculate row number for every image under partition
    # FIXME: was joins(:taxa, :species, :cards), producting overcomplicated join (some tables joined 2-3 times)
    # probably can be refactored taking into account media_observations automatic joins
    window =
        Image.select("media.*, row_number() over (partition by species.id #{PREV_NEXT_ORDER}) as rn").
            joins(
<<SQL
            INNER JOIN "media_observations" ON "media_observations"."media_id" = "media"."id"
            INNER JOIN "observations" ON "observations"."id" = "media_observations"."observation_id"
            INNER JOIN "taxa" ON "taxa"."id" = "observations"."taxon_id"
            INNER JOIN "cards" ON "cards"."id" = "observations"."card_id"
            INNER JOIN "species" ON "species"."id" = "taxa"."species_id"
SQL
            ).
            where("species.id = ?", sp.id)
    # Join ranked tables by neighbouring images
    # Select neighbours of the sought one, exclude duplication
    q = "with ranked as (#{window.to_sql})
      select that.*, that.rn - this.rn as diff
      from ranked that
      join ranked this on that.rn between this.rn-1 and this.rn+1
      where this.id='#{self.id}' and this.rn <> that.rn"
    @prev_next[sp] = Image.find_by_sql(q).index_by(&:diff)
  end

  def has_attached_image
    has_image = flickr_id || assets_cache.any? || stored_image.attachment
    if !has_image
      errors.add(:base, "should have image attached")
    end
  end

  def stored_image_valid_content_type
    # Convoluted because not all associations are created for unsaved image
    if stored_image.attachment&.blob && !stored_image&.blob.image?
      errors.add(:stored_image, "should have image content type")
    end
  end

  def blob_uniqueness
    blob = stored_image.attachment&.blob
    if blob
      if Image.joins(:stored_image_attachment).where(active_storage_attachments: {blob_id: blob.id}).where.not(id: self.id).exists?
        errors.add(:stored_image, "blob already in use by another image")
      end
    end
  end

end
