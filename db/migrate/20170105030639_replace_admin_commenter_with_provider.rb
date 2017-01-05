class ReplaceAdminCommenterWithProvider < ActiveRecord::Migration[5.0]
  def change
    Commenter.where(is_admin: true).update_all(provider: "admin")

    remove_column :commenters, :is_admin
  end
end
