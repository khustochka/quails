class Card < ActiveRecord::Base

  EFFORT_TYPES = %w(INCIDENTAL STATIONARY TRAVEL AREA HISTORICAL)

  include DecoratedModel

  include ActiveSupport::NumberHelper

  invalidates CacheKey.lifelist

  belongs_to :locus
  belongs_to :post, -> { short_form }, touch: :updated_at
  has_many :observations, -> { order('observations.id') }, dependent: :restrict_with_exception
  has_many :images, through: :observations
  has_many :videos, through: :observations
  has_many :species, through: :observations
  has_many :spots, through: :observations

  has_many :ebird_submissions, class_name: 'Ebird::Submission', dependent: :delete_all, inverse_of: :card
  has_many :ebird_files, class_name: 'Ebird::File', through: :ebird_submissions, inverse_of: :cards

  validates :locus_id, :observ_date, presence: true
  validates :effort_type, inclusion: EFFORT_TYPES, allow_blank: false
  validate :check_effort, on: :ebird_post
  validates :start_time, format: /\A(\d{1,2}:\d\d)\Z/, allow_blank: false, allow_nil: true
  validates :duration_minutes, numericality: { only_integer: true }, allow_blank: true
  validates :distance_kms, numericality: {greater_than: 0}, allow_blank: true
  validates :start_time, :duration_minutes, :distance_kms, presence: true, on: :travel
  validates :start_time, :duration_minutes, :area_acres, presence: true, on: :area
  validates :start_time, :duration_minutes, presence: true, on: :stationary

  accepts_nested_attributes_for :observations,
                                reject_if:
                                    proc { |attrs| attrs.all? { |k, v| v.blank? || k == 'voice' } }

  def self.default_cards_order(asc_or_desc)
    order("observ_date #{asc_or_desc}, to_timestamp(start_time, 'HH24:MI') #{asc_or_desc} NULLS LAST")
  end

  def start_time=(str)
    if str.is_a?(String) && str.strip.empty?
      super(nil)
    else
      super(str)
    end
  end


  def secondary_posts
    Post.distinct.joins(:observations).where('observations.card_id = ? AND observations.post_id <> ?', self.id, self.post_id)
  end

  def mapped?
    spots.any?
  end

  def mapped_observations
    self.observations.joins(:spots).distinct
  end

  def mapped_percentage
    number_to_percentage(mapped_observations.count * 100.0 / observations.count, precision: 0)
  end

  # List of new species
  def new_species_ids
    subquery = "select obs.id from observations obs join cards c on obs.card_id = c.id where observations.species_id = obs.species_id and '#{self.observ_date}' > c.observ_date"
    @new_species_ids ||= self.observations.
        where("NOT EXISTS(#{subquery})").
        pluck(:species_id)
  end

  def check_effort
    if non_incidental?
      self.valid?(effort_type.downcase.to_sym)
    end
  end

  def non_incidental?
    effort_type.in? %w(TRAVEL AREA STATIONARY)
  end

  # HISTORICAL is neither incidental, nor non-incidental
  def incidental?
    effort_type == "INCIDENTAL"
  end

  def ebird_id=(val)
    super(val.presence)
  end

  def self.first_unebirded_date
    unebirded.order(:observ_date => :asc).first.try(:observ_date)
  end

  def self.last_unebirded_date
    unebirded.order(:observ_date => :desc).first.try(:observ_date)
  end

  private

  def self.unebirded
    ebirded = Card.select(:id).joins(:ebird_files).where("ebird_files.status IN ('NEW', 'POSTED')")
    self.where("id NOT IN (#{ebirded.to_sql})").where(ebird_id: nil)
  end

end
