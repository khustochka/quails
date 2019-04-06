class SetLengthLimits < ActiveRecord::Migration[4.2]
  def self.up
    change_column :locus, :code, :string, :limit => 32
    change_column :locus, :loc_type, :string, :limit => 8
    change_column :posts, :code, :string, :limit => 64
    change_column :posts, :topic, :string, :limit => 4
    change_column :posts, :status, :string, :limit => 4
    change_column :species, :avibase_id, :string, :limit => 16
  end

  def self.down
  end
end
