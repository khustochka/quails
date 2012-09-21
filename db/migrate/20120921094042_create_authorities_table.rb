class CreateAuthoritiesTable < ActiveRecord::Migration
  def change
    create_table :authorities do |t|
      t.string  "slug",         :limit => 32, :null => false
      t.string  "name"
      t.text  "description"
    end
  end
end
