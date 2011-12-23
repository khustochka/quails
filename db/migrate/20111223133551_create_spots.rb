class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.belongs_to :observation
      t.float :lat
      t.float :lng
      t.integer :zoom
      t.integer :exactness
      t.boolean :public
      t.string :memo
    end

    change_table(:images) do |t|
      t.belongs_to :spot
    end

  end
end
