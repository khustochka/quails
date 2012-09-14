class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  TYPES = %w(Country Region Location)

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

  scope :countries, where(loc_type: 0).order(:public_index)

  scope :public, where('public_index IS NOT NULL').order(:public_index)

  # Instance methods

  def checklist
    species.ordered_by_taxonomy.all.extend(SpeciesArray)
  end

  def subregion_ids
    result = bunch = [self.id]
    until bunch.empty?
      bunch = Locus.where(:parent_id => bunch).pluck(:id)
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
