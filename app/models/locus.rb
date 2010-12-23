class Locus < ActiveRecord::Base

  # TYPES_ORDER = {'Company' => 1, 'Region' => 2, 'Location' => 3}

  validates :code, :format => /^[a-z_]+$/i, :uniqueness => true, :presence => true
  validates :loc_type, :inclusion => ['Country', 'Region', 'Location'], :presence => true

  belongs_to :parent, :class_name => 'Locus'

  scope :list_order, order(:loc_type, :parent_id, :code)

  def to_param
    code
  end

  def self.all_ordered
    list_order.partition { |loc| loc.loc_type != 'Location' }.flatten
  end

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
