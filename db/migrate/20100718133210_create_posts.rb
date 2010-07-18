class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :code, :index => true
      t.string :title
      t.text :text
      t.string :topic, :index => true
      t.string :status, :index => true
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
