class AddSpeciesColumnsForTaxonomyUpdate < ActiveRecord::Migration[6.1]
  def change
    add_column :species, :name_en_overwritten, :boolean, default: false, null: false
    remove_column :species, :reviewed
    add_column :species, :needs_review, :boolean, default: false, null: false
    add_timestamps :species, null: true
    overrides = ["Rough-legged Buzzard", "Great White Egret", "Griffon Vulture", "Woodlark"]
    Species.where(name_en: overrides).update_all(name_en_overwritten: true)
  end
end
