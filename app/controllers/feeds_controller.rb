class FeedsController < ApplicationController
  respond_to :xml

  def blog
    @posts = Post.public.order('face_date DESC').limit(10)
  end
end