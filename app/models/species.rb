class Species < ActiveRecord::Base

#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+( \(?[a-z]+\)?)+$/
  validates :code, :format => /^[a-z]{6}$/, :allow_blank => true

  default_scope order(:index_num)
  scope :alphabetic, unscoped.order(:name_sci)

  has_many :observations

#  has_one :first_observation, :class_name => 'Observation', :conditions =>
#    "
#      mine = 't'
#      AND
#      NOT EXISTS (SELECT * FROM observations ob1
#      WHERE ob1.mine = 't'
#      AND ob1.species_id = observations.species_id
#      AND ob1.observ_date < observations.observ_date
#      )
#    "

  def to_param
    name_sci.gsub(' ', '_')
  end

  def name
    fb = %w(en ru uk)
    until fb.last == I18n.locale.to_s
      fb.pop
    end
    nm = send("name_#{fb.pop}".to_sym) while nm.blank?
    nm
  end

end
