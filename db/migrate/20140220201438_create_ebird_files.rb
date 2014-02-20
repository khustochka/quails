class CreateEbirdFiles < ActiveRecord::Migration
  def change
    create_table :ebird_files do |t|
      t.string :name, null: false
      t.string :status, null: false, default: 'NEW'

      t.timestamps
    end
  end
end
