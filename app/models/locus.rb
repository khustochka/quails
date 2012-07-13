class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  TYPES = %w(Country Region Location)

  PUBLIC_LOCI = %w(ukraine kiev brovary kiev_obl zhytomyr_obl chernihiv_obl kherson_obl zaporizh_obl krym usa)

  validates :slug, :format => /^[a-z_]+$/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :loc_type, :presence => true
  # FIXME: allow blank because imported locations do not have eng, ukr names
  validates :name_en, :name_ru, :name_uk, :uniqueness => true, :allow_blank => true

  belongs_to :parent, :class_name => 'Locus'
  has_many :children, :class_name => 'Locus', :foreign_key => 'parent_id', :dependent => :restrict

  has_many :observations, :dependent => :restrict

  has_many :checklists
  has_many :species, :through => :checklists, :select => '*'

  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  scope :list_order, order('loc_type DESC', :parent_id, :slug)

  scope :countries, where(loc_type: 0)

  scope :public, where(slug: PUBLIC_LOCI)

  # Instance methods

  def checklist
    species.ordered_by_taxonomy.all.extend(SpeciesArray)
  end

  def get_subregions
    result = bunch = [self]
    until bunch.empty?
      bunch = Locus.select(:id).where(:parent_id => bunch).all
      result.concat(bunch)
    end
    result
  end

  def country
    @country ||= if loc_type == 0
                   self
                 else
                   parent.country
                 end
  end

end
