class CreateAuthoritiesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :authorities do |t|
      t.string  "slug",         :limit => 32, :null => false
      t.string  "name", limit: 255
      t.text  "description"
    end
  end
end
