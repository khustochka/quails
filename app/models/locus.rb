class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  TYPES = %w(Country Region Location)

  validates :slug, :format => /\A[a-z_]+\Z/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :loc_type, :presence => true
  validates :name_en, :name_ru, :name_uk, :uniqueness => true

  belongs_to :parent, :class_name => 'Locus'
  has_many :children, :class_name => 'Locus', :foreign_key => 'parent_id', :dependent => :restrict

  has_many :cards, dependent: :restrict
  has_many :observations, through: :cards

  has_many :local_species

  after_save do
    Rails.cache.delete_matched(/subregion_ids/)
  end

  after_save do
    Rails.cache.delete_matched(/subregion_ids/)
  end


  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  scope :list_order, lambda { order('loc_type DESC', :parent_id, :slug) }

  scope :public, lambda { where('public_index IS NOT NULL').order(:public_index) }

  # Instance methods

  def checklist(to_include = [])
    book = Book.find_by_slug('fesenko-bokotej') if slug == 'ukraine'

    local_species.
        joins(:taxa => to_include).includes(:taxa => to_include).
        merge(book.taxa.scoped).
        order("taxa.index_num").
        extending(SpeciesArray)
  end

  def subregion_ids
    Rails.cache.fetch("subregion_ids/#{self.slug}") do
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

      Locus.connection.select_rows(query, "Locus Load").map! { |a| a[0].to_i }.push(self.id)
    end
  end

  def country
    @country ||= if loc_type == 0
                   self
                 else
                   parent.country
                 end
  end

end
