class LifelistSweeper < ActionController::Caching::Sweeper
  observe Observation, Card
  # FIXME: Currently does not sweep on species rename, post URL change (slug or date)

  def after_save(rec)
    expire_fragment %r[/my/lists.*]
  end

  def after_destroy(rec)
    expire_fragment %r[/my/lists.*]
  end
end
