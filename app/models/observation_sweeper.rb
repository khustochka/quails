class ObservationSweeper < ActionController::Caching::Sweeper
  observe Observation

  def after_create(obs)
    expire_fragment(controller: 'lists')
  end

  def after_update(obs)
    expire_fragment(controller: 'lists')
  end

  def after_destroy(obs)
    expire_fragment(controller: 'lists')
  end
end