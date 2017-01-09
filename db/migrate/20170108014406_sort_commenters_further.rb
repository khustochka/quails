class SortCommentersFurther < ActiveRecord::Migration[5.0]
  def change

    Commenter.where(provider: nil).where("email IS NOT NULL").update_all(provider: "email")

    Comment.where(commenter_id: nil).each do |comment|
      author = Commenter.create!(name: comment.name, url: comment.url, provider: "guest")
      comment.update_attribute(:commenter_id, author.id)
    end

    remove_column :comments, :name
    remove_column :comments, :url

  end
end
