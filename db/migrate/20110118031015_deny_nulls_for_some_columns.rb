class DenyNullsForSomeColumns < ActiveRecord::Migration
  def self.up
    change_column :posts, :title, :string, :null => false
    change_column :posts, :text, :text, :null => false
    change_column :posts, :created_at, :datetime, :null => false
    change_column :posts, :updated_at, :datetime, :null => false
  end

  def self.down
    change_column :posts, :title, :string, :null => true
    change_column :posts, :text, :text, :null => true
    change_column :posts, :created_at, :datetime, :null => true
    change_column :posts, :updated_at, :datetime, :null => true
  end
end
