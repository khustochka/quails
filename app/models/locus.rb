class Locus < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

  has_ancestry

  validates :slug, :format => /\A[a-z_]+\Z/i, :uniqueness => true, :presence => true, :length => {:maximum => 32}
  validates :name_en, :name_ru, :name_uk, :uniqueness => true

  has_many :cards, dependent: :restrict_with_exception
  has_many :observations, through: :cards

  has_many :local_species

  after_save do
    Rails.cache.delete_matched %r{records/loci}
  end

  after_save do
    Rails.cache.delete_matched %r{records/loci}
  end

  TYPES = %w(continent country subcountry state oblast raion city)

  # Parameters

  def to_param
    slug_was
  end

  def to_label
    name_en
  end

  # Scopes

  def self.suggestion_order
    sort_by_ancestry(Locus.all)
    # Rails.cache.fetch("records/loci/suggestion_order") do
    #   query = <<-SQL
    #   WITH RECURSIVE subregions(id) AS (
    #     SELECT *, 0 as level
    #     FROM loci
    #     WHERE parent_id IS NULL
    #       UNION ALL
    #     SELECT loci.*, (subregions.level + 1) as level
    #     FROM loci JOIN subregions ON loci.parent_id = subregions.id
    #   )
    #   SELECT * FROM subregions ORDER BY level DESC, parent_id, id
    #   SQL
    #   find_by_sql(query)
    # end
  end

  scope :public, lambda { where('public_index IS NOT NULL').order(:public_index) }

  # Instance methods

  def checklist(to_include = [])
    book_taxa = Taxon.where(book_id: 1) if slug == 'ukraine'

    local_species.
        joins(:taxa => to_include).includes(:taxa => to_include).
        merge(book_taxa).
        order("taxa.index_num").
        extending(SpeciesArray)
  end

  def subregion_ids
    subtree_ids
    # Rails.cache.fetch("records/loci/#{self.slug}/subregion_ids") do
    #   # Hack for Arabat Spit
    #   if self.slug == 'arabat_spit'
    #     Locus.where("slug LIKE 'arabat%'").pluck(:id)
    #   else
    #     # WARNING: PostgreSQL specific syntax
    #     # Learnt from: http://blog.hashrocket.com/posts/recursive-sql-in-activerecord
    #     query = <<-SQL
    #         WITH RECURSIVE subregions(id) AS (
    #           SELECT id
    #           FROM loci
    #           WHERE parent_id = #{self.id}
    #             UNION ALL
    #           SELECT loci.id
    #           FROM loci JOIN subregions ON loci.parent_id = subregions.id
    #         )
    #         SELECT * FROM subregions
    #     SQL
    #
    #     Locus.connection.select_rows(query, "Locus Load").map! { |a| a[0].to_i }.push(self.id)
    #   end
    # end
  end

  def country
    ancestors.where(loc_type: 'country').first
    # @country ||= if parent_id.nil?
    #                self
    #              else
    #                query = <<-SQL
    #                   WITH RECURSIVE parents AS (
    #                     SELECT *
    #                     FROM loci
    #                     WHERE id = #{self.parent_id}
    #                       UNION ALL
    #                     SELECT loci.*
    #                     FROM loci JOIN parents ON loci.id = parents.parent_id
    #                   )
    #                   SELECT * FROM parents WHERE parent_id IS NULL LIMIT 1
    #                SQL
    #                Locus.find_by_sql(query).first
    #              end
  end

  def public_locus
    ancestors.where(private_loc: false).last
    # @public_locus ||= if !private_loc?
    #                     self
    #                   else
    #                     query = <<-SQL
    #                   WITH RECURSIVE parents AS (
    #                     SELECT *
    #                     FROM loci
    #                     WHERE id = #{self.parent_id}
    #                       UNION ALL
    #                     SELECT loci.*
    #                     FROM loci JOIN parents ON loci.id = parents.parent_id
    #                     WHERE parents.private_loc = 't'
    #                   )
    #                   SELECT * FROM parents WHERE private_loc = 'f' LIMIT 1
    #                     SQL
    #                     Locus.find_by_sql(query).first
    #                   end
  end

end
