class Comment < ActiveRecord::Base
  validates :text, :name, :post_id, :presence => true

  belongs_to :post
  has_many :subcomments, :class_name => 'Comment', :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :parent_comment, :class_name => 'Comment', :foreign_key => :parent_id

  before_save do
    self.approved = true if self.approved.nil?
  end

  default_scope { order(:created_at) }

end
