class BlogController < ApplicationController

  before_filter :only => [:front_page, :year, :month] do
    @feed = 'blog'
  end

  POSTS_ON_FRONT_PAGE = 5

  # GET /
  def front_page
    # Read the desired number of posts + 1
    @posts = Post.public.order('face_date DESC').limit(POSTS_ON_FRONT_PAGE + 1).all
    if @posts.size > POSTS_ON_FRONT_PAGE
      post_pre_last = @posts[-2].to_month_url
      post_last = @posts.last.to_month_url
      if post_pre_last != post_last
        # If the last post belong to the different month it is not shown
        # but is used to generate the 'Previous month' link
        @prev_month = post_last
        @posts.pop
      else
        # we fetch and show all the rest of posts
        @posts.concat(
            Post.public.month(post_last[:year], post_last[:month]).
                reorder('face_date DESC').where("id NOT IN (?)", @posts.map(&:id))
        )
        @prev_month = Post.public.prev_month(post_last[:year], post_last[:month])
      end
    end
  end

  def archive
    @years = current_user.available_posts.years
    @archive = current_user.available_posts.
        select("EXTRACT(year FROM face_date) as raw_year,
                EXTRACT(month FROM face_date) as raw_month,
                COUNT(id) as posts_count").
        group(:raw_year, :raw_month).
        order(:raw_year, :raw_month).
        chunk(&:raw_year)
  end

  def month
    @posts = current_user.available_posts.month(@year = params[:year], @month = params[:month])
    @prev_month = current_user.available_posts.prev_month(@year, @month)
    @next_month = current_user.available_posts.next_month(@year, @month)
  end

  def year
    @posts = current_user.available_posts.year(@year = params[:year])
    @months = @posts.chunk(&:month)
    @years = current_user.available_posts.years
  end

end
