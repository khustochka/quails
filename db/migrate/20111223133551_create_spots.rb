class CreateSpots < ActiveRecord::Migration[4.2]
  def change
    create_table :spots do |t|
      t.belongs_to :observation
      t.float :lat
      t.float :lng
      t.integer :zoom
      t.integer :exactness
      t.boolean :public
      t.string :memo, limit: 255
    end

    change_table(:images) do |t|
      t.belongs_to :spot
    end

  end
end
