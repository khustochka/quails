class AddStatusToImages < ActiveRecord::Migration
  def change
    add_column :images, :status, :string, limit: 5, default: 'DEFLT', null: false
  end
end
