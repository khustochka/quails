class MakeLanguageRequiredForPosts < ActiveRecord::Migration[7.0]
  def change
    change_column :posts, :lang, :string, limit: 2, null: false
  end
end
