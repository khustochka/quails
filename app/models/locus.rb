class Locus < ActiveRecord::Base

  TYPES_ORDER = {'Company' => 1, 'Region' => 2, 'Location' => 3}

  validates :code, :format => /^[a-z_]+$/i
  validates :loc_type, :inclusion => ['Country', 'Region', 'Location'] 

  default_scope :order => [:loc_type, :parent_id, :code]

  belongs_to :parent, :class_name => 'Locus'

  def to_param
    code
  end

  def self.all_ordered
    all = Locus.all
    all.select { |loc| loc.loc_type == 'Country' } +
            all.select { |loc| loc.loc_type == 'Region' } +
            all.select { |loc| loc.loc_type == 'Location' }
  end

  def self.get_subregions(loc_ids)
    loc2 = loc_ids.is_a?(Array) ? loc_ids : [loc_ids]
    subregs = where(:parent_id => loc2).map {|loc| loc.id }
    loc2 + (subregs.blank? ? [] : get_subregions(subregs))
  end

end
