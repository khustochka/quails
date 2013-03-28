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
    expire_fragment(controller: :countries, action: :gallery, country: 'ukraine')
    expire_fragment(controller: :countries, action: :gallery, country: 'usa')
    expire_fragment(controller: :species, action: :gallery)
  end
end
