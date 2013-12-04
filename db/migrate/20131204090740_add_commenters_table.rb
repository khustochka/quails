class AddCommentersTable < ActiveRecord::Migration
  def change
    remove_column :comments, :uid
    remove_column :comments, :provider
    remove_column :comments, :email
    add_column :comments, :send_email, :boolean, default: 'f'

    create_table :commenters do |t|
      t.string :email
      t.string :name
      t.boolean :is_admin, default: 'f'
    end

  end
end
