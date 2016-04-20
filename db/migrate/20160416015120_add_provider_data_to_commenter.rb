class AddProviderDataToCommenter < ActiveRecord::Migration
  def change
    add_column :commenters, :provider, :string
    add_column :commenters, :auth_hash, :text
  end
end
