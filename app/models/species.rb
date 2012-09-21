class Species < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => true
  validates :code, :format => /^[a-z]{6}$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true
  validates :legacy_slug, :format => /^[A-Z][a-z]+_[a-z]+$/, :uniqueness => true

  has_many :observations, :dependent => :restrict, :order => [:observ_date]
  has_many :images, :through => :observations, :order => [:observ_date, :locus_id, :index_num]

  AVIS_INCOGNITA = OpenStruct.new(id: 0, name_sci: '- Avis incognita', to_label: '- Avis incognita')

  # Parameters

  def to_param
    legacy_slug_was.sp_parameterize
  end

  def to_label
    name_sci
  end

  # Scopes

  scope :ordered_by_taxonomy, order(:index_num)

  scope :alphabetic, order(:name_sci)

end
