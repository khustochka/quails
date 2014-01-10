class AddObsIndexOnCards < ActiveRecord::Migration
  def change
    add_index "observations", ["card_id"]
  end
end
