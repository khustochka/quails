# frozen_string_literal: true

require "species_parameterizer"

class Species < ApplicationRecord
  extend SpeciesParameterizer

  invalidates CacheKey.gallery
  invalidates CacheKey.lifelist

  localized_attr :name

  validates :order, presence: true
  validates :family, presence: true
  validates :name_sci, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/, uniqueness: true
  validates :code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true, allow_blank: false
  validates :legacy_code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true, allow_blank: false
  # validates :avibase_id, format: /\A[\dA-F]{16}\Z/, allow_blank: true
  validates :index_num, presence: true

  validate :code_and_legacy_code_uniqueness

  acts_as_list column: :index_num

  has_one :species_image
  has_one :image, through: :species_image

  has_many :taxa
  has_many :high_level_taxa, -> { where(taxa: { category: "species" }) }, class_name: "Taxon"
  has_many :observations, through: :taxa

  has_many :cards, through: :observations
  has_many :loci, through: :cards
  has_many :images, through: :observations
  has_many :videos, through: :observations
  # has_many :posts, -> { order(face_date: :desc).distinct }, through: :observations

  has_many :local_species
  has_many :url_synonyms

  has_many :splits_super, class_name: "SpeciesSplit", foreign_key: "superspecies_id"
  has_many :splits_sub, class_name: "SpeciesSplit", foreign_key: "subspecies_id"

  has_many :superspecies, through: :splits_sub, primary_key: "superspecies_id"
  has_many :subspecies, through: :splits_super, primary_key: "subspecies_id"

  # Scopes

  scope :short, lambda { select("species.id, species.name_sci, species.name_en, species.name_ru, species.name_uk, species.index_num") }

  scope :ordered_by_taxonomy, lambda { distinct.reorder("species.index_num") }

  def ordered_images
    images.order_for_species
  end

  def posts
    p1 = observations.select(:post_id)
    p2 = cards.select(:post_id)

    Post.short_form.distinct.where("posts.id IN (?) OR posts.id IN (?)", p1, p2).order(face_date: :desc)
  end

  def high_level_taxon
    high_level_taxa.first
  end

  # Parameters

  accepts_nested_attributes_for :species_image

  def to_param
    Species.parameterize(name_sci_was)
  end

  def code_or_slug
    code.presence || to_param
  end

  def to_label
    name_sci
  end

  def code=(val)
    super(val.presence)
  end

  def legacy_code=(val)
    super(val.presence)
  end

  # Methods

  def update_image
    reload
    if !image
      self.image = images.first || nil
      save!
    end
  end

  def the_rest_of_images
    images.where("media.id NOT IN (?)", SpeciesImage.where(species: self).select(:image_id))
  end

  def self.thumbnails
    all.map(&:to_thumbnail)
  end

  def grouped_loci
    countries = Country.select(:id, :slug, :ancestry).to_a
    subregions = Hash[countries.map { |c| [c, c.subregion_ids] }]
    loci.distinct.group_by do |locus|
      countries.find { |c| locus.id.in?(subregions[c]) }.slug
    end
  end

  def main_taxon
    taxa.where(category: "species").first
  end

  # Formatting

  def to_thumbnail
    Thumbnail.new(self, { partial: "species/thumb_title" }, image)
  end

  # Validations

  def code_and_legacy_code_uniqueness
    if legacy_code.present? && Species.where("id != ?", id).exists?(code: legacy_code)
      errors.add(:legacy_code, "already exists as a code")
    end
    if code.present? && Species.where("id != ?", id).exists?(legacy_code: code)
      errors.add(:code, "already exists as a legacy code")
    end
  end
end
