require 'species_parameterizer'

class Species < ActiveRecord::Base

  extend SpeciesParameterizer

  include ActiveRecord::Localized
  localize :name

  serialize :wikidata, Hash

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => true
  validates :code, :format => /\A[a-z]{6}\Z/, :uniqueness => true, :allow_blank => true
  validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true

  has_many :observations, :dependent => :restrict, :order => [:observ_date]
  has_many :cards, :through => :observations
  # FIXME: turn back ordering
  has_many :images, :through => :observations #, :order => [:observ_date, :locus_id, :index_num, :created_at, 'images.id']
  has_many :taxa
  has_many :posts, through: :observations, order: 'face_date DESC', uniq: true

  belongs_to :image

  AVIS_INCOGNITA = Struct.new(:id, :name_sci, :to_label, :name).
      new(0, '- Avis incognita', '- Avis incognita', '- Avis incognita')

  # Parameters

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

  def update_image
    self.reload
    if !image_id || !image
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

end
