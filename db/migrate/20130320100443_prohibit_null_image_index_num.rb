class ProhibitNullImageIndexNum < ActiveRecord::Migration
  def up
    change_column :images, :index_num, :integer, null: false, default: 1000
  end

  def down
  end
end
