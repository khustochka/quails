class Locus < ActiveRecord::Base

  TYPES = %w(Country Region Location)

  validates :code, :format => /^[a-z_]+$/i, :uniqueness => true, :presence => true, :length => { :maximum => 32 }
  validates :loc_type, :inclusion => TYPES, :presence => true, :length => { :maximum => 8 }

  belongs_to :parent, :class_name => 'Locus'

  has_many :observations, :dependent => :restrict

  # Parameters

  def to_param
    code
  end

  # Scopes

  scope :list_order, order(:loc_type, :parent_id, :code)

  def self.all_ordered
    list_order.partition { |loc| loc.loc_type != 'Location' }.flatten
  end

  # Instance methods

  def get_subregions
    Locus.bulk_subregions_finder(self)
  end

  private
  def self.bulk_subregions_finder(loc_ids)
    parent_locs = Array.wrap(loc_ids)
    subregs     = select(:id).where(:parent_id => parent_locs).all
    parent_locs + (subregs.blank? ? [] : bulk_subregions_finder(subregs))
  end

end
