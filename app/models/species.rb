class Species < ActiveRecord::Base

  include ActiveRecord::Localized
  localize :name

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => true
  validates :code, :format => /^[a-z]{6}$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true

  has_many :observations, :dependent => :restrict, :order => [:observ_date]
  has_many :images, :through => :observations, :order => [:observ_date, :locus_id, :index_num]

  AVIS_INCOGNITA = OpenStruct.new(:id => 0, :name_sci => '- Avis incognita')

  # Parameters

  def to_param
    name_sci_was.sp_parameterize
  end

  # Scopes

  default_scope order(:index_num)

  def self.alphabetic
    reorder(:name_sci)
  end

end
