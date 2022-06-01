class LimitUnsubscribeTokenLength < ActiveRecord::Migration[6.1]
  def change
    # Usually the length is 20, but urlsafe_base64 docs say:
    # The length of the result string is about 4/3 of n.
    change_column :comments, :unsubscribe_token, :string, limit: 25
  end
end
