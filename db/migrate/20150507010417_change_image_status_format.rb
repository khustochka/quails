class ChangeImageStatusFormat < ActiveRecord::Migration
  def change
    change_column :media, :status, :string, limit: 16, default: "PUBLIC"

    Media.where(status: "DEFLT").update_all(status: "PUBLIC")
    Media.where(status: "NOIDX").update_all(status: "NOINDEX")

  end
end
