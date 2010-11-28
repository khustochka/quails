class Locus < ActiveRecord::Base

  # TYPES_ORDER = {'Company' => 1, 'Region' => 2, 'Location' => 3}

  validates :code, :format => /^[a-z_]+$/i, :uniqueness => true
  validates :loc_type, :inclusion => ['Country', 'Region', 'Location']

  belongs_to :parent, :class_name => 'Locus'

  def to_param
    code
  end

  def self.all_ordered
    all = order(:loc_type, :parent_id, :code)
    all.select { |loc| loc.loc_type == 'Country' } +
        all.select { |loc| loc.loc_type == 'Region' } +
        all.select { |loc| loc.loc_type == 'Location' }
  end

  def get_subregions
    Locus.bulk_subregions_finder(self)
  end

  private
  def self.bulk_subregions_finder(loc_ids)
    parent_locs = loc_ids.is_a?(Array) ? loc_ids : [loc_ids]
    subregs     = select(:id).where(:parent_id => parent_locs).all
    parent_locs + (subregs.blank? ? [] : bulk_subregions_finder(subregs))
  end

end
