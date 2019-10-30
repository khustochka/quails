class AccomodateIPv6Addresses < ActiveRecord::Migration[6.1]
  def change
    change_column :comments, :ip, :string, limit: 45
  end
end
