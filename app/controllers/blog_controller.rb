class BlogController < ApplicationController

  before_filter :only => [:index, :year, :month] do
    @feed = 'blog'
  end

  POSTS_ON_FRONT_PAGE = 10

  # GET /
  def front_page
    @posts = current_user.available_posts.order('face_date DESC').limit(POSTS_ON_FRONT_PAGE + 1).all
    if @posts.size > POSTS_ON_FRONT_PAGE
      post_1 = @posts[0].to_month_url
      post_last = @posts[-1].to_month_url
      if post_1 != post_last
        @prev_month = post_last
        @posts.pop
      else
        @posts.concat current_user.available_posts.order('face_date DESC').where(
                          'EXTRACT(year from face_date) = ? AND EXTRACT(month from face_date) = ?', post_last[:year], post_last[:month]
                      ).offset(POSTS_ON_FRONT_PAGE + 1)
        @prev_month = current_user.available_posts.prev_month(post_last[:year], post_last[:month])
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @posts }
    end
  end

  def month
    @posts = current_user.available_posts.month(@year = params[:year], @month = params[:month])
    @prev_month = current_user.available_posts.prev_month(@year, @month)
    @next_month = current_user.available_posts.next_month(@year, @month)
  end

  def year
    @posts = current_user.available_posts.year(@year = params[:year])
    @months = @posts.group_by(&:month)
    @years = current_user.available_posts.years
  end

end
