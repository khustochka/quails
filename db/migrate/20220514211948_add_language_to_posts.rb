class AddLanguageToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :lang, :string, limit: 2
    Post.update_all(lang: -"ru")
  end
end
