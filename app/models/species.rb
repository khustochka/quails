class Species < ActiveRecord::Base
#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => true
  validates :code, :format => /^[a-z]{6}$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true

  has_many :observations, :dependent => :restrict, :order => [:observ_date]
  has_many :images, :through => :observations, :order => [:observ_date, :locus_id, :index_num]

  AVIS_INCOGNITA = Hashie::Mash.new(:id => 0, :name_sci => '- Avis incognita')

  # Parameters

  def to_param
    name_sci_was.sp_parameterize
  end

  # Scopes

  default_scope order(:index_num)

  def self.alphabetic
    reorder(:name_sci)
  end

  # Instance methods

  def name
    fb = %w(en ru uk)
    until fb.last == I18n.locale.to_s
      fb.pop
    end
    nm = send("name_#{fb.pop}".to_sym) while nm.blank?
    nm
  end

  def first_date
    Date.parse(read_attribute(:first_date))
  end

  def last_date
    Date.parse(read_attribute(:last_date))
  end

end
