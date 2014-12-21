class Image < Media
  include FormattedModel

  invalidates CacheKey.gallery

  NORMAL_PARAMS = [:slug, :title, :description, :index_num, :has_old_thumbnail, :status]

  STATES = %w(DEFLT NOIDX)

  default_scope -> { where(media_type: 'photo') }

  has_many :children, -> { basic_order }, class_name: 'Image', foreign_key: 'parent_id'

  validates :external_id, uniqueness: true, allow_nil: true, exclusion: {in: ['']}

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

  scope :basic_order, -> { order(:index_num, 'media.created_at', 'media.id') }

  # Photos with several species
  def self.multiple_species
    rel = select(:media_id).from("media_observations").group(:media_id).having("COUNT(observation_id) > 1")
    select("DISTINCT media.*, observ_date").where(id: rel).
        joins(:observations, :cards).preload(:species).order('observ_date ASC')
  end

  def self.half_mapped
    Image.preload(:species).joins(:observations).
        where(spot_id: nil).where("observation_id in (select observation_id from spots)").
        order(created_at: :asc)
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

  def multi?
    species.count > 1
  end

  ORDERING_COLUMNS = %w(cards.observ_date cards.locus_id index_num media.created_at media.id)
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

  # Formatting

  def to_thumbnail
    title = self.formatted.title
    child_num = children.size
    if child_num > 0
      title = "#{title} (#{child_num + 1} #{I18n.t('images.series_photos_num')})"
    end
    Thumbnail.new(self, title, self, {image: {id: id}})
  end

  private

  def prev_next_by(sp)
    @prev_next ||= {}
    if @prev_next[sp]
      return @prev_next[sp]
    end
    # Calculate row number for every image under partition
    window =
        Image.select("media.*, row_number() over (partition by species_id #{PREV_NEXT_ORDER}) as rn").
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

end
