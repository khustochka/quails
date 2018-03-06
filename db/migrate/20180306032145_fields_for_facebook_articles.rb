class FieldsForFacebookArticles < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :cover_image_slug, :string, null: true
    add_column :posts, :publish_to_facebook, :boolean, default: false, null: false
  end
end
