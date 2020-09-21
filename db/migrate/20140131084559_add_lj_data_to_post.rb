class AddLJDataToPost < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :lj_data, :text
  end
end
