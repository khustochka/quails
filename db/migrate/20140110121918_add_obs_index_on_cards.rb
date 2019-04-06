class AddObsIndexOnCards < ActiveRecord::Migration[4.2]
  def change
    add_index "observations", ["card_id"]
  end
end
