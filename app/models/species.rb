class Species < ActiveRecord::Base
#  validates :order, :presence => true, :allow_blank => true
  validates :family, :presence => true
  validates :name_sci, :format => /^[A-Z][a-z]+ [a-z]+$/, :uniqueness => true
  validates :code, :format => /^[a-z]{6}$/, :uniqueness => true
  validates :avibase_id, :format => /^[\dA-F]{16}$/, :allow_blank => true

  has_many :observations, :dependent => :restrict, :order => [:observ_date]

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

  def self.old_lifelist(*args)
    options = args.extract_options!
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
            'first_date DESC, index_num DESC'
          #TODO: implement correct processing of incorrect query parameters
          # raise 'Incorrect option'
        end
    select('obs.*, name_sci, name_ru, name_en, name_uk, index_num, family, "order"').reorder(sort_option).
        joins("INNER JOIN (#{Observation.old_lifers_observations(options).to_sql}) AS obs ON species.id=obs.main_species").
        all.group_by(&:main_species).map { |_, v| v.first }
  end

  def self.lifelist(*args)
    options = args.extract_options!
    sort_columns =
        case options[:sort]
          when nil, 'count'
            'aggregated_value DESC, index_num DESC'
          when 'class'
            'index_num ASC'
          else
            #TODO: implement correct processing of incorrect query parameters
            raise 'Incorrect option'
        end
    select('species.*, aggregated_value').
        joins(
          "INNER JOIN (%s) AS obs ON species.id=obs.species_id" %
              Observation.lifers_aggregation(options).to_sql
        ).
        reorder(sort_columns)

  end

  # Associations

  def images
    Observation.where(:species_id => id).includes(:images).map(&:images).flatten
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
