class Species < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /\A[A-Z][a-z]+ [a-z]+\Z/, :uniqueness => true
  validates :code, :format => /\A[a-z]{6}\Z/, :uniqueness => true, :allow_blank => true
  validates :avibase_id, :format => /\A[\dA-F]{16}\Z/, :allow_blank => true

  has_many :observations, -> { order :observ_date }, dependent: :restrict_with_exception
  has_many :images, -> { order(:observ_date, :locus_id, :index_num) }, through: :observations
  has_many :taxa
  has_many :posts, through: :observations, order: 'face_date DESC', uniq: true

  belongs_to :image

  AVIS_INCOGNITA = Struct.new(:id, :name_sci, :to_label, :name).
      new(0, '- Avis incognita', '- Avis incognita', '- Avis incognita')

  # Parameters

  def to_param
    name_sci_was.sp_parameterize
  end

  def to_label
    name_sci
  end

  # Scopes

  scope :ordered_by_taxonomy, lambda { order("species.index_num") }

  scope :alphabetic, lambda { order(:name_sci) }

end
