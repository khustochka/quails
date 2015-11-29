require 'species_parameterizer'

class Species < ActiveRecord::Base

  extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  validates :order, presence: true
  validates :family, presence: true
  validates :name_sci, presence: true, format: /\A[A-Z][a-z]+ [a-z]+\Z/, uniqueness: true
  validates :code, format: /\A[a-z]{6}\Z/, uniqueness: true, allow_nil: true
  #validates :avibase_id, format: /\A[\dA-F]{16}\Z/, allow_blank: true
  validates :index_num, presence: true

  acts_as_ordered :index_num

  has_one :species_image
  has_one :image, through: :species_image

  has_many :taxa
  has_many :observations, through: :taxa

  has_many :cards, through: :observations
  has_many :loci, through: :cards
  has_many :images, through: :observations
  has_many :videos, through: :observations
  has_many :posts, -> { order(face_date: :desc).uniq }, through: :observations

  scope :ordered_by_taxonomy, lambda { uniq.reorder("species.index_num") }

  def ordered_images
    images.order_for_species
  end

  # Parameters

  accepts_nested_attributes_for :species_image

  def to_param
    Species.parameterize(name_sci_was)
  end

  def to_label
    name_sci
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
    loci.uniq.group_by do |locus|
      countries.find {|c| locus.id.in?(c.subregion_ids)}.slug
    end
  end

  # Formatting

  def to_thumbnail
    Thumbnail.new(self, {partial: 'species/thumb_title'}, self.image)
  end

end
