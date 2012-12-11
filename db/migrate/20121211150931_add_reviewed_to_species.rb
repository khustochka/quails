class AddReviewedToSpecies < ActiveRecord::Migration
  def change
    add_column :species, :reviewed, :boolean, null: false, default: false
  end
end
