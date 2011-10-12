class PostsController < ApplicationController

  requires_admin_authorized :except => [:index, :year, :month, :show]

  layout 'admin', :except => [:index, :year, :month, :show]

  before_filter :find_post, :only => [:edit, :update, :destroy, :show]

  POSTS_ON_FRONT_PAGE = 10

  # GET /
  def index
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
    @posts      = current_user.available_posts.month(@year = params[:year], @month = params[:month])
    @prev_month = current_user.available_posts.prev_month(@year, @month)
    @next_month = current_user.available_posts.next_month(@year, @month)
  end

  def year
    @posts  = current_user.available_posts.year(@year = params[:year])
    # TODO: there is problem with timezone
    @months = @posts.group_by(&:month)
    @years  = current_user.available_posts.years
  end

  # GET /posts/1
  def show
    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post), :status => 301
    end
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    @extra_params = @post.to_url_params
  end

  # POST /posts
  def create
    @post = Post.new(params[:post])

    if @post.save
      redirect_to(public_post_path(@post), :notice => 'Post was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /posts/1
  def update
    @extra_params = @post.to_url_params
    if @post.update_attributes(params[:post])
      redirect_to(public_post_path(@post), :notice => 'Post was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to(root_url)
  end

  private

  def find_post
    @post = current_user.available_posts.find_by_code!(params[:id])
  end

end