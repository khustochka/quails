class ChecklistSweeper < ActionController::Caching::Sweeper
  observe Taxon, LocalSpecies

  def after_save(rec)
    expire_fragment(controller: :checklist, action: :show, country: 'ukraine')
  end
end
