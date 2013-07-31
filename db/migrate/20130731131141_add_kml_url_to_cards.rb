class AddKmlUrlToCards < ActiveRecord::Migration
  def change
    add_column :cards, :kml_url, :string, null: false, default: ""
  end
end
