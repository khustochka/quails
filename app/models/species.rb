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

  def self.lifelist(*args)
    options     = args.extract_options!
    sort_option =
        case options.delete(:sort)
          when nil
            'first_date DESC, index_num DESC'
          when 'last' then
            'last_date DESC, index_num DESC'
          when 'count' then
            'view_count DESC, index_num ASC'
          when 'class'
            'index_num ASC'
          else
            raise 'Incorrect option'
        end
    select('*').joins("INNER JOIN (#{Observation.lifers_dates(options).to_sql}) AS obs ON species.id=obs.species_id").\
    except(:order).order(sort_option)
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