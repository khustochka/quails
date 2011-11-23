class Comment < ActiveRecord::Base
  belongs_to :post

  default_scope joins(:post).order('posts.face_date', :created_at)

end
