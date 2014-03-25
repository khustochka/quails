class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  has_ancestry orphan_strategy: :restrict

  validates :slug, :format => /\A[a-z_]+\Z/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :name_en, :name_ru, :name_uk, :uniqueness => true

  has_many :cards, dependent: :restrict_with_exception
  has_many :observations, through: :cards

  has_many :local_species

  after_save do
    Rails.cache.delete_matched %r{records/loci}
  end

  after_save do
    Rails.cache.delete_matched %r{records/loci}
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

  scope :public, lambda { where('public_index IS NOT NULL').order(:public_index) }

  # Instance methods

  def checklist(to_include = [])
    book_taxa = Taxon.where(book_id: 1) if slug == 'ukraine'

    local_species.
        joins(:taxa => to_include).includes(:taxa => to_include).
        merge(book_taxa).
        order("taxa.index_num").
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
    path.where(private_loc: false).last
  end

end
