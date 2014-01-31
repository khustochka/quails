class AddLjDataToPost < ActiveRecord::Migration
  def change
    add_column :posts, :lj_data, :text
  end
end
