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

  has_many :local_species

  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  scope :list_order, lambda { order('loc_type DESC', :parent_id, :slug) }

  scope :countries, lambda { where(loc_type: 0).order(:public_index) }

  scope :public, lambda { where('public_index IS NOT NULL').order(:public_index) }

  # Instance methods

  def checklist
    local_species.includes(:species).order("species.index_num").extend(SpeciesArray)
  end

  def subregion_ids
    # WARNING: PostgreSQL specific syntax
    # Learnt from: http://blog.hashrocket.com/posts/recursive-sql-in-activerecord
    query = <<-SQL
      WITH RECURSIVE subregions(id) AS (
        SELECT id
        FROM loci
        WHERE parent_id = #{self.id}
          UNION ALL
        SELECT loci.id
        FROM loci JOIN subregions ON loci.parent_id = subregions.id
      )
      SELECT * FROM subregions
    SQL

    Locus.connection.select_rows(query, "Locus Load").map! {|a| a[0].to_i }.push(self.id)
  end

  def country
    @country ||= if loc_type == 0
                   self
                 else
                   parent.country
                 end
  end

end
