class ObservationBulk

  # Required dependency for ActiveModel::Errors
  # extend ActiveModel::Naming
  # extend ActiveModel::Translation
  # extend ActiveModel::Validations

  def initialize(params)
    @common = params[:c]
    @observations = Array.wrap(params[:o]).map {|ob| ob.merge(@common)}
    @errors = ActiveModel::Errors.new(self)
  end

  attr_reader :errors

  def save
    test_obs = Observation.new({:species_id => 0}.merge(@common))
    test_obs.valid?
    test_obs.errors.each { |attr, err| errors.add(attr, err) }
    @observations.map! do |obs|
      Observation.create(obs)
    end
    errors.add(:base, 'provide at least one observation') if @observations.blank?
    errors.add(:base, 'not saved') if errors.blank? && @observations.find {|o| !o.errors.blank? }
    
    errors.blank?
  end

  def to_json(options={})
    (errors.blank? ?
      {:result => 'OK', :data => @observations} :
      {:result => 'Error', :errors => errors, :data => @observations.map {|o| o.errors.to_hash}}
    ).to_json(options)
  end

end