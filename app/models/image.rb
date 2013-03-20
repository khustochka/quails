class Image < ActiveRecord::Base
  include FormattedModel

  validates :slug, :uniqueness => true, :presence => true, :length => {:maximum => 64}

  has_and_belongs_to_many :observations
  has_many :species, :through => :observations
  has_many :spots, :through => :observations
  belongs_to :spot

  delegate :observ_date, :locus, :locus_id, :to => :first_observation

  serialize :flickr_data, Hash

  # Callbacks
  after_create do
    species.each(&:update_image)
  end

  after_destroy do
    species.each(&:update_image)
  end

  # Parameters

  def to_param
    slug_was
  end

  # Photos with several species
  def self.multiple_species
    rel = select(:image_id).from("images_observations").group(:image_id).having("COUNT(observation_id) > 1")
    where(id: rel).preload(:species).order('created_at ASC')
  end

  # Associations

  def post(posts_source)
    posts_source.find_by_id(first_observation.post_id)
  end

  # Instance methods

  def on_flickr?
    flickr_id.present?
  end

  def multi?
    species.count > 1
  end

  ORDERING_COLUMNS = %w(observ_date locus_id index_num created_at)

  def prev_by_species(sp)
    sp.images.
        where("#{ORDERING_COLUMNS.map {|c| "#{c} <= ?"}.join(' AND ')} AND images.id < ?",
              *ORDERING_COLUMNS.map {|c| self.send(c.to_sym)}, self.id)
    .order("#{ORDERING_COLUMNS.map {|c| "#{c} DESC"}.join(', ')}, images.id DESC").first
  end

  def next_by_species(sp)
    sp.images.
        where("#{ORDERING_COLUMNS.map {|c| "#{c} >= ?"}.join(' AND ')}  AND images.id > ?",
              *ORDERING_COLUMNS.map {|c| self.send(c.to_sym)}, self.id)
    .order("#{ORDERING_COLUMNS.map {|c| "#{c} ASC"}.join(', ')}, images.id ASC").first
  end

  def public_title
    title.present? ? title : species[0].name # Not using || because of empty string possibility
  end

  def search_applicable_observations
    Observation.search(
        new_record? ?
            {:observ_date => Observation.select('MAX(observ_date) AS last_date').first.last_date} :
            {:observ_date => observ_date, :locus_id => locus.id}
    )
  end

  def set_flickr_data(flickr, parameters = {})
    self.flickr_id = parameters[:flickr_id] || flickr_id
    if self.flickr_id.present?
      sizes_array = flickr.photos.getSizes(photo_id: flickr_id)
      self.flickr_data = Hash[
          sizes_array.map do |el|
            [el['label'], el.to_hash.slice('width', 'height', 'source')]
          end
      ]
    end
  end

  # Saving with observation validation

  def update_with_observations(attr, obs_ids)
    assign_attributes(attr)
    validate_observations(obs_ids)
    if errors.any?
      run_validations!
      return false
    end
    with_transaction_returning_status do
      if self.spot_id && !self.spot.observation.in?(self.observation_ids & obs_ids)
        self.spot_id = nil
      end
      self.observation_ids = obs_ids.uniq
      run_validations! && save.tap do |result|
        if result
          self.species.each(&:update_image)
        end
      end
    end
  end

  private

  def first_observation
    observations[0]
  end

  COMMON_OBSERVATION_ATTRIBUTES = %w(observ_date locus_id mine)

  def validate_observations(observ_ids)
    obs = Observation.where(:id => observ_ids)
    if obs.blank?
      errors.add(:observations, 'must not be empty')
    else
      if obs.map { |o| o.attributes.values_at(*COMMON_OBSERVATION_ATTRIBUTES) }.uniq.size > 1
        errors.add(:observations, 'must have the same date, location, and mine value')
      end
    end
  end

end
