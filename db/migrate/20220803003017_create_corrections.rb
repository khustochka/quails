class CreateCorrections < ActiveRecord::Migration[7.0]
  def change
    create_table :corrections do |t|
      t.string :model_classname, null: false
      t.string :query, null: false
      t.string :sort_column, null: false, default: "created_at"

      t.timestamps
    end
  end
end
