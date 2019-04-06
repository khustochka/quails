class CreatePosts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :posts do |t|
      t.string :code
      t.string :title, limit: 255
      t.text :text
      t.string :topic
      t.string :status
      t.integer :lj_post_id
      t.integer :lj_url_id

      t.timestamps

    end

    add_index :posts, :code
    add_index :posts, :topic
    add_index :posts, :status
    add_index :posts, :created_at

  end

  def self.down
    drop_table :posts
  end
end
