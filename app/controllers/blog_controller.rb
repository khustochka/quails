class BlogController < ApplicationController

  before_filter :only => [:index, :year, :month] do
    @feed = 'blog'
  end

  POSTS_ON_FRONT_PAGE = 10

  # GET /
  def front_page
    # Read the desired number of posts + 1
    @posts = current_user.available_posts.order('face_date DESC').limit(POSTS_ON_FRONT_PAGE + 1).all
    if @posts.size > POSTS_ON_FRONT_PAGE
      post_1 = @posts.first.to_month_url
      post_last = @posts.last.to_month_url
      if post_1 != post_last
        # If the last post belong to the different month it is not shown
        # but is used to generate the 'Previous month' link
        @prev_month = post_last
        @posts.pop
      else
        # If all posts belong to the same month we fetch and show all the rest of posts
        @posts.concat(
            current_user.available_posts.order('face_date DESC').where(
                'EXTRACT(year from face_date) = ? AND EXTRACT(month from face_date) = ?', post_last[:year], post_last[:month]
            ).offset(POSTS_ON_FRONT_PAGE + 1)
        )
        @prev_month = current_user.available_posts.prev_month(post_last[:year], post_last[:month])
      end
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
