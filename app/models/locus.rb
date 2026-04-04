# frozen_string_literal: true

class Locus < ApplicationRecord
  include DecoratedModel

  localized_attr :name

  invalidates Quails::CacheKey.lifelist

  has_ancestry orphan_strategy: :restrict

  # NOTE: These methods are purely for presentation. They are not updated automatically if ancestry is updated!
  belongs_to :cached_parent, class_name: "Locus", optional: true
  belongs_to :cached_city, class_name: "Locus", optional: true
  belongs_to :cached_subdivision, class_name: "Locus", optional: true
  belongs_to :cached_country, class_name: "Locus", optional: true
  belongs_to :cached_public_locus, class_name: "Locus", optional: true

  has_many :cards, dependent: :restrict_with_exception
  has_many :observations, through: :cards

  has_many :local_species, dependent: :delete_all

  belongs_to :ebird_location, optional: true

  validates :slug, format: /\A[a-z_0-9]+\Z/i, uniqueness: true, presence: true, length: { maximum: 32 }
  validates :name_en, :name_ru, :name_uk, uniqueness: true
  validates :cached_country, presence: true, if: ->(loc) { loc.path.where(loc_type: "country").any? && loc.cached_country_id.nil? }

  after_initialize :prepopulate, unless: :persisted?
  before_validation :generate_slug
  before_validation :set_country
  after_create :set_and_save_cached_public_locus
  before_update :set_cached_public_locus, if: -> { will_save_change_to_private_loc? || will_save_change_to_ancestry? }
  after_save :update_descendants_public_locus, if: -> { saved_change_to_private_loc? || saved_change_to_ancestry? }
  normalizes :loc_type, with: ->(v) { v.presence }

  TYPES = %w(continent country region raion city)

  # Parameters

  def to_param
    slug_was
  end

  def to_label
    I18n.with_locale(:en) do
      decorated.short_full_name
    end
  end

  # Scopes

  scope :cached_ancestry_preload, -> { preload(:cached_parent, :cached_city, :cached_subdivision, :cached_country, :cached_public_locus) }

  def self.suggestion_order
    sort_by_ancestry(all.cached_ancestry_preload).reverse
  end

  scope :locs_for_lifelist, lambda { where.not(public_index: nil).order(:public_index) }

  scope :non_private, lambda { where("private_loc = 'f'") }

  # Instance methods

  # Override ancestry method, memoize
  def parent
    return @__parent if @parent_loaded

    super.tap do |parent_loc|
      @__parent = parent_loc
      @parent_loaded = true
    end
  end

  def checklist(to_include = [])
    local_species
      .joins(species: to_include)
      .preload(species: to_include)
      .order("species.index_num")
      .extending(SpeciesArray)
  end

  def subregion_ids
    # Hack for Arabat Spit
    if slug == "arabat_spit"
      Locus.where("slug LIKE 'arabat%'").flat_map(&:subtree_ids)
    elsif slug == "5mr"
      Locus.where(five_mile_radius: true).map(&:id)
    else
      subtree_ids
    end
  end

  def country
    path.where(loc_type: "country").first
  end

  def public_locus
    cached_public_locus
  end

  def short_name
    if patch
      [cached_parent, self].compact.uniq.map(&:name).join(" - ")
    else
      name
    end
  end

  def country?
    loc_type == "country"
  end

  def compute_cached_public_locus_id
    if private_loc
      ancestors.to_a.rfind { |l| !l.private_loc }&.id
    else
      id
    end
  end

  private

  def set_parent(p) # rubocop:disable Naming/AccessorMethodName
    # Can be Country
    if p.kind_of?(Locus) # rubocop:disable Style/ClassCheck
      @__parent = p
      @parent_loaded = true
      @__parent
    end
  end

  def generate_slug
    slug.presence || (self.slug = name_en.downcase.delete("'").gsub(" - ", "_").gsub("--", "_").gsub(/[^\d\w_]+/, "_"))
  end

  def set_country
    if !country?
      self.cached_country_id = country&.id
    end
  end

  def generate_lat_lon
    unless lat && lon
      num = /-?\d+(?:\.\d+)?/
      if (m = name_en.match(/(#{num})[,;]\s*(#{num})/))
        self.lat = m[1].to_f
        self.lon = m[2].to_f
      end
    end
  end

  def prepopulate
    if name_en.present?
      generate_slug
      generate_lat_lon
      name_ru.presence || (self.name_ru = name_en)
      name_uk.presence || (self.name_uk = name_en)
    end
  end

  # Used by before_update: id already exists, so we can set the value in the same UPDATE statement.
  def set_cached_public_locus
    self.cached_public_locus_id = compute_cached_public_locus_id
  end

  # Used by after_create: id is not yet assigned at before_save time (for public loci cached_public_locus_id = id),
  # so we need a separate UPDATE after the INSERT.
  def set_and_save_cached_public_locus
    update_column(:cached_public_locus_id, compute_cached_public_locus_id)
  end

  # Used by after_save: when private_loc or ancestry changes, descendants' nearest public ancestor may change too.
  # Runs after self is already saved so its own cached_public_locus_id is correct.
  def update_descendants_public_locus
    descendants.each do |desc|
      desc.update_column(:cached_public_locus_id, desc.compute_cached_public_locus_id)
    end
  end

  # Use when necessary
  def cache_parent_loci
    anc = ancestors.to_a
    cnt_id = anc.find { |l| l.loc_type == "country" && !l.private_loc }&.id
    sub_id = anc.find { |l| l.loc_type == "region" && !l.private_loc }&.id
    city_id = anc.find { |l| l.loc_type == "city" && !l.private_loc }&.id
    self.cached_parent_id = parent_id unless parent_id.in?([cnt_id, sub_id, city_id]) || parent.private_loc
    self.cached_city_id = city_id
    self.cached_subdivision_id = sub_id
    self.cached_country_id = cnt_id
  end
end
