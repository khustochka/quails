class AddTimeStampsToImages < ActiveRecord::Migration[4.2]

  class Image < ActiveRecord::Base

  end

  def up
    add_column :images, :updated_at, :timestamp

    Image.update_all(updated_at: Time.zone.now)

    change_column :images, :updated_at, :timestamp, null: false
    change_column :images, :created_at, :timestamp, null: false
  end

  def down
    change_column :images, :created_at, :timestamp, null: true

    remove_column :images, :updated_at
  end
end
