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

  has_many :cards, dependent: :restrict_with_exception
  has_many :observations, through: :cards

  has_many :local_species, dependent: :delete_all

  belongs_to :ebird_location, optional: true

  validates :slug, format: /\A[a-z_0-9]+\Z/i, uniqueness: true, presence: true, length: { maximum: 32 }
  validates :name_en, :name_ru, :name_uk, uniqueness: true

  after_initialize :prepopulate, unless: :persisted?
  before_validation :generate_slug

  TYPES = %w(continent country subcountry state oblast raion city)

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

  scope :cached_ancestry_preload, -> { preload(:cached_parent, :cached_city, :cached_subdivision, :cached_country) }

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
    if !private_loc
      self
    else
      if !parent.private_loc
        parent
      else
        parent.public_locus
      end
    end
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

  # Use when necessary
  def cache_parent_loci
    anc = ancestors.to_a
    cnt_id = anc.find { |l| l.loc_type == "country" && !l.private_loc }&.id
    sub_id = anc.find { |l| l.loc_type.in?(%w(state oblast)) && !l.private_loc }&.id
    city_id = anc.find { |l| l.loc_type == "city" && !l.private_loc }&.id
    self.cached_parent_id = parent_id unless parent_id.in?([cnt_id, sub_id, city_id]) || parent.private_loc
    self.cached_city_id = city_id
    self.cached_subdivision_id = sub_id
    self.cached_country_id = cnt_id
  end
end
