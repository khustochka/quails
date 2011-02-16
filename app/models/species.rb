class Species < ActiveRecord::Base

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+( \(?[a-z]+\)?)+$/, :uniqueness => true
  validates :code, :format => /^[a-z]{6}$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/

  has_many :observations, :dependent => :restrict

  # Parameters

  def to_param
    name_sci.gsub(' ', '_')
  end

  # Scopes

  default_scope order(:index_num)

  def self.alphabetic
    except(:order).order(:name_sci)
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

end
