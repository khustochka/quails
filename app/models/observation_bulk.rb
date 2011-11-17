class ObservationBulk < Array

  def initialize(params)
    @errors = HashWithIndifferentAccess.new
    common = params[:c]
    @test_obs = Observation.new(common)
    common[:post_id] ||= nil # Explicitly unlink post if check box is unchecked
    super(
        Array.wrap(params[:o]).map do |ind|
          o = Observation.find_or_initialize_by_id(ind[:id])
          o.assign_attributes(ind.merge(common))
          o
        end
    )
  end

  attr_reader :errors

  def save
    # Validate dummy observation to collect errors in common params
    @test_obs.send(:run_validations!)
    @test_obs.errors.to_hash.slice(:locus_id, :observ_date).each do |attr, msg|
      @errors[attr] = [] unless @errors[attr]
      @errors[attr].concat(msg)
    end

    # Save all observations and collect errors
    obs_errors = []
    Observation.new.with_transaction_returning_status do
      self.map! do |obs|
        obs.save
        obs_errors << obs.errors.to_hash.slice!(:locus_id, :observ_date)
        obs
      end
      obs_errors.clear if obs_errors.reject(&:empty?).empty?
    end
    @errors[:base] = ['provide at least one observation'] if self.blank?
    @errors[:observs] = obs_errors
    @errors.delete_if { |_, val| val.empty? }
    @errors.blank?
  end

end