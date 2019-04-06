class AddIpColumnToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :ip, :string, limit: 15
  end
end
