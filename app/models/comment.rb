class Comment < ActiveRecord::Base
  validates :text, :name, :post_id, :presence => true

  belongs_to :post

  default_scope order(:created_at)

end
