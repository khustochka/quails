class Locus < ActiveRecord::Base
  include DecoratedModel

  include ActiveRecord::Localized
  localize :name

  invalidates CacheKey.lifelist

  has_ancestry orphan_strategy: :restrict

  validates :slug, :format => /\A[a-z_0-9]+\Z/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :name_en, :name_ru, :name_uk, :uniqueness => true

  has_many :cards, dependent: :restrict_with_exception
  has_many :observations, through: :cards
  has_many :patch_observations, class_name: 'Observation', foreign_key: 'patch_id', dependent: :restrict_with_exception

  has_many :local_species

  after_save do |record|
    Rails.cache.delete("records/loci/country/#{record.slug}")
  end

  TYPES = %w(continent country subcountry state oblast raion city)

  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  def self.suggestion_order
    sort_by_ancestry(Locus.all).reverse
  end

  scope :locs_for_lifelist, lambda { where('public_index IS NOT NULL').order(:public_index) }

  scope :non_private, lambda { where("private_loc = 'f'") }

  # Instance methods

  def checklist(to_include = [])
    local_species.
        joins(species: to_include).
        preload(species: to_include).
        order("species.index_num").
        extending(SpeciesArray)
  end

  def subregion_ids
    # Hack for Arabat Spit
    if slug == 'arabat_spit'
      Locus.where("slug LIKE 'arabat%'").pluck(:id)
    else
      subtree_ids
    end
  end

  def country
    path.where(loc_type: 'country').first
  end

  def public_locus
    path.where(private_loc: false, patch: false).last
  end

end
