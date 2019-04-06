class AddKmlUrlToCards < ActiveRecord::Migration[4.2]
  def change
    add_column :cards, :kml_url, :string, limit: 255, null: false, default: ""
  end
end
