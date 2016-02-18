class AddPrivateNotesToObservations < ActiveRecord::Migration
  def up
    rename_column :observations, :place, :private_notes
    add_column :observations, :place, :string
  end

  def down
    remove_column :observations, :place
    rename_column :observations, :private_notes, :place
  end
end
