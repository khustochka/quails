# frozen_string_literal: true

class Card < ApplicationRecord
  class UnsplittableCard < StandardError
  end

  attribute :ebird_id, :nullable_string
  attribute :start_time, :nullable_string

  EFFORT_TYPES = %w(INCIDENTAL STATIONARY TRAVEL AREA HISTORICAL)
  NON_INCIDENTAL = EFFORT_TYPES - %w(INCIDENTAL HISTORICAL)

  include DecoratedModel

  include ActiveSupport::NumberHelper

  invalidates Quails::CacheKey.lifelist

  belongs_to :locus, -> { cached_ancestry_preload }, inverse_of: :cards
  belongs_to :post, -> { short_form }, touch: true, optional: true, inverse_of: :cards
  has_many :observations, -> { order("observations.id") }, dependent: :restrict_with_exception, inverse_of: :card
  has_many :mapped_observations, -> { joins(:spots).distinct }, class_name: "Observation", inverse_of: :card, dependent: nil

  has_many :taxa, through: :observations
  has_many :species, through: :taxa
  has_many :images, through: :observations, inverse_of: :cards
  has_many :videos, through: :observations, inverse_of: :cards
  has_many :spots, through: :observations, inverse_of: :cards

  has_many :ebird_submissions, class_name: "EBird::Submission", dependent: :delete_all, inverse_of: :card
  has_many :ebird_files, class_name: "EBird::File", through: :ebird_submissions, inverse_of: :cards

  validates :observ_date, presence: true
  validates :effort_type, inclusion: EFFORT_TYPES, allow_blank: false
  validate :check_effort, on: :ebird_post
  validates :start_time, format: /\A(\d{1,2}:\d\d)\Z/, allow_blank: false, allow_nil: true
  validates :duration_minutes, numericality: { only_integer: true }, allow_blank: true
  validates :distance_kms, numericality: { greater_than: 0 }, allow_blank: true
  validates :start_time, :duration_minutes, :distance_kms, presence: true, on: :travel
  validates :start_time, :duration_minutes, :area_acres, presence: true, on: :area
  validates :start_time, :duration_minutes, presence: true, on: :stationary
  validates :ebird_id, uniqueness: true, allow_blank: true

  accepts_nested_attributes_for :observations,
    reject_if: proc { |attrs| attrs.all? { |k, v| v.blank? || k.in?(%w(voice hidden)) } }

  # Eligible for ebird challenge: full non-incidental checklist without X's (all quantities in numbers)
  scope :ebird_eligible, -> {
    where(effort_type: NON_INCIDENTAL)
      .where("NOT EXISTS (select id from observations where card_id = cards.id and quantity !~ '\\A\\d+')")
  }

  scope :in_year, ->(year) { where("EXTRACT(year FROM observ_date) = ?", year) }

  scope :default_cards_order, ->(asc_or_desc) {
    raise "Invalid order (only ASC and DESC accepted)." unless asc_or_desc.to_s.downcase.in? %w(asc desc)

    order(observ_date: asc_or_desc)
      .order(Arel.sql("to_timestamp(start_time, 'HH24:MI') #{asc_or_desc} NULLS LAST"))
  }

  def secondary_posts
    Post.distinct.joins(:observations).where("observations.card_id = ? AND observations.post_id <> ?", id, post_id)
  end

  def mapped?
    spots.any?
  end

  def mapped_percentage
    number_to_percentage(mapped_observations.size * 100.0 / observations.size, precision: 0)
  end

  # List of lifer species
  def lifer_species_ids
    subquery = "
        select obs.id
        from observations obs
        join cards c on obs.card_id = c.id
        join taxa tt ON obs.taxon_id = tt.id
        where taxa.species_id = tt.species_id and
        ('#{observ_date}' > c.observ_date
         " +
      (
        if start_time.blank?
          "OR ('#{observ_date}' = c.observ_date
                AND c.start_time IS NOT NULL
                )
        OR ('#{observ_date}' = c.observ_date
                AND c.start_time IS NULL
                AND c.id < #{id}
                )"
        else
          "OR ('#{observ_date}' = c.observ_date
                AND to_timestamp('#{start_time}', 'HH24:MI') > to_timestamp(c.start_time, 'HH24:MI')
                )"
        end
      ) +
      ")"
    @lifer_species_ids ||= observations
      .identified
      .where("NOT EXISTS(#{subquery})")
      .pluck(:species_id)
  end

  def check_effort
    if non_incidental?
      valid?(effort_type.downcase.to_sym)
    end
  end

  def non_incidental?
    effort_type.in? NON_INCIDENTAL
  end

  # HISTORICAL is neither incidental, nor non-incidental
  def incidental?
    effort_type == "INCIDENTAL"
  end

  class << self
    def first_unebirded_date
      unebirded.order(observ_date: :asc).first.try(:observ_date)
    end

    def last_unebirded_date
      unebirded.order(observ_date: :desc).first.try(:observ_date)
    end

    def unebirded
      ebirded = Card.select(:id).joins(:ebird_files).where("ebird_files.status IN ('NEW', 'POSTED')")
      where("id NOT IN (#{ebirded.to_sql})").where(ebird_id: nil)
    end
  end
end
