class Comment < ActiveRecord::Base
  validates :text, :name, :post_id, :presence => true

  belongs_to :post

  before_save do
    self.approved = true if self.approved.nil?
  end

  default_scope order(:created_at)

end
