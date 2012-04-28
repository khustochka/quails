class Locus < ActiveRecord::Base

  TYPES = %w(Country Region Location)

  validates :code, :format => /^[a-z_]+$/i, :uniqueness => true, :presence => true, :length => { :maximum => 32 }
  validates :loc_type, :presence => true
  # FIXME: allow blank because imported locations do not have eng, ukr names
  validates :name_en, :name_ru, :name_uk, :uniqueness => true, :allow_blank => true

  belongs_to :parent, :class_name => 'Locus'
  has_many :children, :class_name => 'Locus', :foreign_key => 'parent_id', :dependent => :restrict

  has_many :observations, :dependent => :restrict

  # Parameters

  def to_param
    code_was
  end

  # Scopes

  scope :list_order, order('loc_type DESC', :parent_id, :code)

  # Instance methods

  def get_subregions
    result = bunch = [self]
    until bunch.empty?
      bunch = Locus.select(:id).where(:parent_id => bunch).all
      result.concat(bunch)
    end
    result
  end

end
