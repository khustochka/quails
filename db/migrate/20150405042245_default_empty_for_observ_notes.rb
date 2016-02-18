class DefaultEmptyForObservNotes < ActiveRecord::Migration
  def change
    change_column :observations, "private_notes", :string, limit: 255, null: false, default: ""
    change_column :observations, "notes", :string, limit: nil, null: false, default: ""
    change_column :observations, "place", :string, limit: 255, null: false, default: ""
  end
end
