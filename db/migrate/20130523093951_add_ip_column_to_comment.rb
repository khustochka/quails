class AddIpColumnToComment < ActiveRecord::Migration
  def change
    add_column :comments, :ip, :string, limit: 15
  end
end
