class UnsubscribeTokenForComment < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :unsubscribe_token, :string, length: 64
    Comment.where(send_email: true).each do |comment|
      comment.update_attribute(:unsubscribe_token, SecureRandom.urlsafe_base64(20 * 3 / 4))
    end
  end
end
