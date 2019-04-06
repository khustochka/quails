class AddCommentersTable < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :uid
    remove_column :comments, :provider
    remove_column :comments, :email
    add_column :comments, :send_email, :boolean, default: 'f'

    create_table :commenters do |t|
      t.string :email, limit: 255
      t.string :name, limit: 255
      t.boolean :is_admin, default: 'f'
    end

  end
end
