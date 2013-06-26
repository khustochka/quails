class GallerySweeper < ActionController::Caching::Sweeper
  observe Species, Taxon
  #FIXME: will not sweep if species image existed before, but only recently added to country USA
  # This is a rare case, observing Observation will be an overhead

  def after_save(rec)
    sweep_galleries
  end

  def after_destroy(rec)
    sweep_galleries
  end

  private
  def sweep_galleries
    expire_fragment %r[/ukraine.*]
    expire_fragment %r[/usa.*]
    expire_fragment %r[/species.*]
  end
end
