class TimestampsForCommenters < ActiveRecord::Migration[8.1]
  def change
    add_column :commenters, :created_at, :datetime
    add_column :commenters, :updated_at, :datetime
  end
end
