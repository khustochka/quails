class LifelistSweeper < ActionController::Caching::Sweeper
  observe Observation
  # FIXME: Currently does not sweep on species rename, post URL change (slug or date)

  def after_save(obs)
    expire_fragment %r[my/lists.*]
  end

  def after_destroy(obs)
    expire_fragment %r[my/lists.*]
  end
end
