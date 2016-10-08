require 'species_parameterizer'

class Species < ActiveRecord::Base

  extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  validates :order, presence: true
  validates :family, presence: true
  validates :name_sci, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/, uniqueness: true
  validates :code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true, allow_blank: false
  validates :legacy_code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true, allow_blank: false
  #validates :avibase_id, format: /\A[\dA-F]{16}\Z/, allow_blank: true
  validates :index_num, presence: true

  acts_as_ordered :index_num

  has_one :species_image
  has_one :image, through: :species_image

  has_many :taxa
  has_many :high_level_taxa, -> { where(taxa: {category: "species"}) }, class_name: "Taxon"
  has_many :observations, through: :taxa

  has_many :cards, through: :observations
  has_many :loci, through: :cards
  has_many :images, through: :observations
  has_many :videos, through: :observations
  #has_many :posts, -> { order(face_date: :desc).distinct }, through: :observations

  has_many :local_species
  has_many :url_synonyms

  # Scopes

  scope :short, lambda { select("species.id, species.name_sci, species.name_en, species.name_ru, species.name_uk, species.index_num") }

  scope :ordered_by_taxonomy, lambda { uniq.reorder("species.index_num") }

  def ordered_images
    images.order_for_species
  end

  def posts
    p1 = Post.select("posts.id").joins(:observations).where('observations.id' => self.observations.select(:id)).to_sql

    p2 = Post.connection.unprepared_statement do
      Post.select("posts.id").joins(:cards).where("cards.id" => self.cards).to_sql
    end

    Post.distinct.where("posts.id IN (#{p1}) OR posts.id IN (#{p2})").order(face_date: :desc)
  end

  def high_level_taxon
    high_level_taxa.first
  end

  # Parameters

  accepts_nested_attributes_for :species_image

  def to_param
    Species.parameterize(name_sci_was)
  end

  def to_label
    name_sci
  end

  def code=(val)
    super(val == '' ? nil : val)
  end

  def legacy_code=(val)
    super(val == '' ? nil : val)
  end

  # Methods

  def update_image
    self.reload
    if !image
      self.image = self.images.first || nil
      save!
    end
  end

  def self.thumbnails
    all.map(&:to_thumbnail)
  end

  def grouped_loci
    countries = Country.select(:id, :slug, :ancestry).to_a
    loci.distinct.group_by do |locus|
      countries.find {|c| locus.id.in?(c.subregion_ids)}.slug
    end
  end

  def main_taxon
    taxa.where(category: "species").first
  end

  # Formatting

  def to_thumbnail
    Thumbnail.new(self, {partial: 'species/thumb_title'}, self.image)
  end

  def destroy
    raise "Destroying species not allowed!"
  end

end
