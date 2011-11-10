class ObservationBulk
  
  delegate :to_json, :to => :@observations
  
  def initialize(params)
    @common = params[:c]
    @individs = Array.wrap(params[:o])
    @errors = HashWithIndifferentAccess.new
  end

  attr_reader :errors

  def save
    # Validate dummy observation to collect errors in common params
    test_obs = Observation.new(@common)
    test_obs.send(:run_validations!)
    test_obs.errors.to_hash.slice(:locus_id, :observ_date).each do |attr, msg|
      @errors[attr] = [] unless @errors[attr]
      @errors[attr].concat(msg) 
    end
        
    # Save all observations and collect errors
    obs_errors = []
    Observation.new.with_transaction_returning_status do
      @observations = @individs.map do |data|
        obs = Observation.create(data.merge(@common))
        obs_errors << obs.errors.to_hash.slice!(:locus_id, :observ_date)
        obs
      end
      obs_errors.clear if obs_errors.reject(&:empty?).empty?
    end
    @errors[:base] = ['provide at least one observation'] if @observations.blank?
    @errors[:observs] = obs_errors
    @errors.delete_if {|_, val| val.empty?}
    @errors.blank?
  end

end