class Species < ActiveRecord::Base

  validates :order, :presence => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+( [a-z]+)+$/
  validates :code, :format => /^[a-z]{6}$/, :allow_blank => true

  default_scope order(:index_num)
  scope :alphabetic, unscoped.order(:name_sci)

  def to_param
    name_sci.sub(' ', '_')
  end

end
