class LifelistSweeper < ActionController::Caching::Sweeper
  observe Observation

  def after_save(obs)
    expire_fragment(controller: 'lists')
  end

  def after_destroy(obs)
    expire_fragment(controller: 'lists')
  end
end
