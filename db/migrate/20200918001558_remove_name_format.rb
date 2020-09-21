class RemoveNameFormat < ActiveRecord::Migration[6.1]
  def change
    remove_column :loci, :name_format
  end
end
