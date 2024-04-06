class CreateEBirdFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :ebird_files do |t|
      t.string :name, null: false, limit: 255
      t.string :status, null: false, default: 'NEW', limit: 255

      t.timestamps
    end
  end
end
