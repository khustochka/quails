class AddCardsIndices < ActiveRecord::Migration
  def change
    add_index "cards", ["locus_id"]
    add_index "cards", ["post_id"]
    add_index "cards", ["observ_date"]
  end
end
