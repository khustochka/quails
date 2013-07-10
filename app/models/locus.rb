class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  validates :slug, :format => /\A[a-z_]+\Z/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :name_en, :name_ru, :name_uk, :uniqueness => true

  belongs_to :parent, :class_name => 'Locus'
  has_many :children, :class_name => 'Locus', :foreign_key => 'parent_id', :dependent => :restrict

  has_many :cards, dependent: :restrict
  has_many :observations, through: :cards

  has_many :local_species

  after_save do
    Rails.cache.delete_matched %r{records/loci}
  end

  after_save do
    Rails.cache.delete_matched %r{records/loci}
  end


  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  scope :list_order, lambda { order(:parent_id, :slug) }

  def self.suggestion_order
    Rails.cache.fetch("records/loci/suggestion_order") do
      query = <<-SQL
      WITH RECURSIVE subregions(id) AS (
        SELECT *, 0 as level
        FROM loci
        WHERE parent_id IS NULL
          UNION ALL
        SELECT loci.*, (subregions.level + 1) as level
        FROM loci JOIN subregions ON loci.parent_id = subregions.id
      )
      SELECT * FROM subregions ORDER BY level DESC, parent_id, id
      SQL
      find_by_sql(query)
    end
  end

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
    Rails.cache.fetch("records/loci/#{self.slug}/subregion_ids") do
      # Hack for Arabat Spit
      if self.slug == 'arabat_spit'
        Locus.where("slug LIKE 'arabat%'").pluck(:id)
      else
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
  end

  def country
    @country ||= if parent_id.nil?
                   self
                 else
                   query = <<-SQL
                      WITH RECURSIVE parents AS (
                        SELECT *
                        FROM loci
                        WHERE id = #{self.parent_id}
                          UNION ALL
                        SELECT loci.*
                        FROM loci JOIN parents ON loci.id = parents.parent_id
                      )
                      SELECT * FROM parents WHERE parent_id IS NULL LIMIT 1
                   SQL
                   Locus.find_by_sql(query).first
                 end
  end

end
