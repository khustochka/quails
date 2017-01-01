class AddColumnsToCommenters < ActiveRecord::Migration[5.0]
  def change
    add_column :commenters, :uid, :string
    add_column :commenters, :url, :string
    add_column :commenters, :image, :string
    add_column :commenters, :created_at, :datetime
    add_column :commenters, :updated_at, :datetime

  end
end
