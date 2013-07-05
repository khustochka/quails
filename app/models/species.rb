require 'species_parameterizer'

class Species < ActiveRecord::Base

  extend SpeciesParameterizer

  invalidates CacheKey.gallery

  include ActiveRecord::Localized
  localize :name

  serialize :wikidata, Hash

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => true
  validates :code, :format => /\A[a-z]{6}\Z/, :uniqueness => true, :allow_blank => true
  validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true

  has_many :observations, dependent: :restrict_with_exception
  has_many :cards, through: :observations
  has_many :images, through: :observations
  has_many :taxa
  has_many :posts, -> { order('face_date DESC').uniq}, through: :observations

  has_one :species_image
  has_one :image, through: :species_image

  AVIS_INCOGNITA = Struct.new(:id, :name_sci, :to_label, :name).
      new(0, '- Avis incognita', '- Avis incognita', '- Avis incognita')

  # Parameters

  accepts_nested_attributes_for :species_image

  def to_param
    Species.parameterize(name_sci_was)
  end

  def to_label
    name_sci
  end

  # Scopes

  scope :ordered_by_taxonomy, lambda { order("species.index_num") }

  scope :alphabetic, lambda { order(:name_sci) }

  def self.by_abundance
    select('species.id, name_sci').joins("LEFT OUTER JOIN observations on observations.species_id=species.id").
        group('species.id').order('COUNT(observations.id) DESC, name_sci')
  end

  def ordered_images
    images.order_for_species
  end

  def posts
    p1 = Post.select("posts.id").joins(:observations).where('observations.id' => self.observation_ids)
    p2 = Post.select("posts.id").joins(:cards).where("cards.id" => self.cards)
    Post.uniq.where('posts.id IN (?) OR posts.id IN (?)', p1, p2).order('face_date DESC')
  end

  def update_image
    self.reload
    if !image
      self.image = self.images.first || nil
      save!
    end
  end

  # Wikidata

  def wikidata
    Hashie::Mash.new(read_attribute('wikidata'))
  end

  def similar_species
    arr = (wikidata.similar_species || '').split(',').map(&:strip)
    Species.where(code: arr).order(:index_num)
  end

  # Formatting

  def to_thumbnail
    Thumbnail.new(self, {partial: 'species/thumb_title'}, self.image)
  end

end
