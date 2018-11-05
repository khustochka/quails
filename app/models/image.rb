class Image < Media
  include DecoratedModel

  invalidates CacheKey.gallery

  NORMAL_PARAMS = [:slug, :title, :description, :index_num, :has_old_thumbnail, :status]

  STATES = %w(PUBLIC NOINDEX POST_ONLY EBIRD_ONLY PRIVATE)

  default_scope -> { where(media_type: 'photo') }

  has_many :children, -> { basic_order }, class_name: 'Image', foreign_key: 'parent_id'

  has_one_attached :source_image

  validates :external_id, uniqueness: true, allow_nil: true, exclusion: {in: ['']}
  validates :status, inclusion: STATES, presence: true, length: {maximum: 16}

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

  def on_s3?
    source_image.attachment.present?
  end

  def multi?
    species.count > 1
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

end
