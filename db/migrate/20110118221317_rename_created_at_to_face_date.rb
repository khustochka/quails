class RenameCreatedAtToFaceDate < ActiveRecord::Migration
  def self.up
    rename_column :posts, :created_at, :face_date
  end

  def self.down
    rename_column :posts, :face_date, :created_at
  end
end
