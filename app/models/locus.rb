class Locus < ActiveRecord::Base

  TYPES_ORDER = {'Company' => 1, 'Region' => 2, 'Location' => 3}

  validates :code, :format => /^[a-z_]+$/i
  validates :loc_type, :inclusion => ['Country', 'Region', 'Location']

  scope :ordered_for_list, order(:loc_type, :parent_id, :code)

  belongs_to :parent, :class_name => 'Locus'

  def to_param
    code
  end

  def self.all_ordered
    all = Locus.ordered_for_list.all
    all.select { |loc| loc.loc_type == 'Country' } +
        all.select { |loc| loc.loc_type == 'Region' } +
        all.select { |loc| loc.loc_type == 'Location' }
  end

  def self.get_subregions(loc_ids)
    parent_locs = loc_ids.is_a?(Array) ? loc_ids : [loc_ids]
    subregs     = select(:id).where(:parent_id => parent_locs).all
    parent_locs + (subregs.blank? ? [] : get_subregions(subregs))
  end

end
