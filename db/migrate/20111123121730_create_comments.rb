class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.references :post
      t.integer :parent_id
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :url
      t.text :text
      t.boolean :approved

      t.timestamp :created_at
    end

    add_index :comments, :post_id
  end
end
