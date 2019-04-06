class CreatePages < ActiveRecord::Migration[4.2]
  def change
    create_table :pages do |t|
      t.string :slug, null: false
      t.string :title, null: false
      t.text :meta
      t.text :text
      t.boolean :public, default: 'F', null: false

      t.timestamps
    end

    add_index "pages", ["slug"], unique: true
  end
end
