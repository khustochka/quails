# frozen_string_literal: true

class Locus < ApplicationRecord
  include DecoratedModel

  localized_attr :name

  invalidates Quails::CacheKey.lifelist

  has_ancestry orphan_strategy: :restrict

  TYPES = %w(country subdivision1 subdivision2 city site section special)

  # +special+ loci may appear anywhere in the hierarchy and repeat freely.
  SPECIAL_TYPE = "special"

  # Ranked types, ordered from highest (country) to lowest (section). Each may
  # appear at most once on an ancestry path and only below higher-ranked ones.
  RANKED_TYPES = (TYPES - [SPECIAL_TYPE]).freeze

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
  validates :cached_country, presence: true, if: ->(loc) { loc.ancestors.where(loc_type: "country").any? && loc.cached_country_id.nil? }
  validates :loc_type, inclusion: { in: TYPES }, presence: true
  validate :loc_type_hierarchy_valid
  validate :descendants_loc_type_hierarchy_valid,
    if: -> { persisted? && (will_save_change_to_loc_type? || will_save_change_to_ancestry?) }

  after_initialize :prepopulate, unless: :persisted?
  before_validation :generate_slug
  before_validation :set_country
  after_create :set_and_save_cached_public_locus
  before_update :set_cached_public_locus, if: -> { will_save_change_to_private_loc? || will_save_change_to_ancestry? }
  after_save :update_descendants_public_locus, if: -> { saved_change_to_private_loc? || saved_change_to_ancestry? }

  normalizes :iso_code, with: ->(v) { v.presence }
  normalizes :loc_type, with: ->(v) { v.presence }

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

  scope :cached_ancestry_preload, -> {
    preload(:cached_parent, :cached_city, :cached_subdivision, :cached_country,
      cached_public_locus: [:cached_parent, :cached_city, :cached_subdivision, :cached_country])
  }

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

  # Maps each locus in +loci_scope+ to the slug of the country on its ancestry
  # path (or itself, if it is the country). Returns { locus_id => country_slug }
  # in a single query, letting Postgres match the country id against the loci's
  # ancestry path instead of fetching each country's subtree (an N+1).
  def self.country_slug_by_id(loci_scope)
    sql = <<~SQL.squish
      SELECT l.id AS locus_id, c.slug AS country_slug
      FROM (#{loci_scope.reselect(:id, :ancestry).to_sql}) l
      LEFT JOIN loci c ON c.loc_type = 'country'
        AND (c.id = l.id OR c.id = ANY (string_to_array(l.ancestry, '/')::int[]))
    SQL
    connection.select_rows(sql).to_h
  end

  def public_locus
    cached_public_locus
  end

  # Promotes all direct children one level up, re-parenting them to this locus's
  # own parent so they become siblings of this locus instead of its children.
  # (If this locus is a root, the children become roots too.) The children's
  # denormalized cached_* fields are adjusted to keep display names sensible
  # (see #adjust_cached_for_promotion). Returns the number of children moved.
  def promote_children!
    moved = children.to_a
    new_parent = parent
    transaction do
      moved.each do |child|
        child.parent = new_parent
        child.__send__(:adjust_cached_for_promotion, self, new_parent)
        child.save!
      end
    end
    moved.size
  end

  def short_name
    name
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

  # Each ranked (non-special) loc_type must appear at most once on the ancestry
  # path and only below higher-ranked types: e.g. a city may sit below a country
  # or subdivision, but not below another city or a site. +special+ loci are
  # exempt and may be interspersed anywhere. Enforced by requiring the ranked
  # types along the path (ancestors first, self last) to strictly descend in
  # RANKED_TYPES order.
  def loc_type_hierarchy_valid
    conflict = hierarchy_conflict_for(loc_type, ancestors)
    return unless conflict

    errors.add(:loc_type,
      "#{loc_type} cannot be placed below #{conflict.loc_type} (#{conflict.slug})")
  end

  # When this locus's own type or position changes, descendants that were valid
  # may no longer be (e.g. demoting a country to a site can leave a city stranded
  # above a higher-ranked ancestor, or repeat a rank). Re-validate each descendant
  # against the ancestry it will have after the save.
  #
  # Descendant +ancestry+ columns are only rewritten in an after_update callback,
  # so at validation time a descendant's own #ancestors still reflects the old
  # tree. We rebuild each descendant's pending path as: this locus's new path
  # (its fresh ancestors + itself, carrying the pending loc_type) followed by the
  # unchanged chain between this locus and the descendant.
  def descendants_loc_type_hierarchy_valid
    own_new_path = ancestors.to_a + [self]

    subtree = descendants.to_a
    by_id = subtree.index_by(&:id)

    subtree.each do |descendant|
      # The chain strictly between this locus and the descendant, taken from the
      # (still old, but intra-subtree-stable) ancestry path and resolved against
      # the loci we already loaded — no per-descendant query.
      below_self = descendant.ancestor_ids.drop_while { |aid| aid != id }.drop(1).map { |aid| by_id[aid] }
      conflict = hierarchy_conflict_for(descendant.loc_type, own_new_path + below_self)
      next unless conflict

      errors.add(:base,
        "#{descendant.loc_type} #{descendant.slug} cannot be placed below " \
          "#{conflict.loc_type} (#{conflict.slug})")
    end
  end

  # Returns the first ancestor in +path+ (root-first order) that a locus of
  # +type+ may not sit below — i.e. a ranked ancestor of equal or higher rank.
  # Returns nil when +type+ is blank, special, or unranked, or when no ancestor
  # conflicts. +path+ is an enumerable of Locus records.
  def hierarchy_conflict_for(type, path)
    return if type.blank? || type == SPECIAL_TYPE

    own_rank = RANKED_TYPES.index(type)
    return if own_rank.nil?

    # special or unranked ancestors are skipped; a same-or-higher ranked
    # ancestor means this type would repeat or sit above a higher rank.
    path.find do |ancestor|
      ancestor_rank = RANKED_TYPES.index(ancestor.loc_type)
      ancestor_rank && ancestor_rank >= own_rank
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
    self.loc_type ||= "site"
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

  # Called on a child being promoted from +old_parent+ (the locus whose children
  # are being promoted) up to +new_parent+. Keeps the denormalized cached_* chain
  # sensible:
  #   * If cached_parent pointed at the old parent, it is no longer an ancestor, so clear it.
  #   * If the new parent is not already represented anywhere in the cached chain,
  #     record it: as cached_city when it is a city, otherwise as cached_parent.
  def adjust_cached_for_promotion(old_parent, new_parent)
    self.cached_parent_id = nil if cached_parent_id == old_parent.id

    return if new_parent.nil?

    cached_chain = [cached_parent_id, cached_city_id, cached_subdivision_id, cached_country_id]
    return if cached_chain.include?(new_parent.id)

    if new_parent.loc_type == "city"
      self.cached_city_id = new_parent.id
    else
      self.cached_parent_id = new_parent.id
    end
  end

  # Use when necessary
  def cache_parent_loci
    anc = ancestors.to_a
    cnt_id = anc.find { |l| l.loc_type == "country" && !l.private_loc }&.id
    sub_id = anc.find { |l| l.loc_type == "subdivision1" && !l.private_loc }&.id
    city_id = anc.find { |l| l.loc_type == "city" && !l.private_loc }&.id
    self.cached_parent_id = parent_id unless parent_id.in?([cnt_id, sub_id, city_id]) || parent.private_loc
    self.cached_city_id = city_id
    self.cached_subdivision_id = sub_id
    self.cached_country_id = cnt_id
  end
end
