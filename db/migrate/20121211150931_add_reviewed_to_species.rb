class AddReviewedToSpecies < ActiveRecord::Migration[4.2]
  def change
    add_column :species, :reviewed, :boolean, null: false, default: false
  end
end
