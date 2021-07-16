class AddMotorlessToCards < ActiveRecord::Migration[6.1]
  def change
    add_column :cards, :motorless, :boolean, null: false, default: "f"
  end
end
