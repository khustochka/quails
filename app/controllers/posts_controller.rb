class PostsController < ApplicationController

  require_http_auth :except => [:index, :year, :month, :show]

  layout 'admin', :except => [:index, :year, :month, :show]

  use_jquery :only => :edit

  before_filter :find_post, :only => [:public_show, :edit, :update, :destroy, :show]

  POSTS_ON_FRONT_PAGE = 10

  # GET /
  def index
    @posts = SessionAwarePost().order('face_date DESC').limit(POSTS_ON_FRONT_PAGE + 1).all
    if @posts.size > POSTS_ON_FRONT_PAGE
      post_1 = @posts[0].to_month_url
      post_last = @posts[-1].to_month_url
      if post_1 != post_last
        @prev_month = post_last
        @posts.pop
      else
        @posts += SessionAwarePost().order('face_date DESC').where(
            'EXTRACT(year from face_date) = ? AND EXTRACT(month from face_date) = ?', post_last[:year], post_last[:month]
        ).offset(POSTS_ON_FRONT_PAGE + 1)
        @prev_month = SessionAwarePost().prev_month(post_last[:year], post_last[:month])
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @posts }
    end
  end

  def month
    @posts      = SessionAwarePost().month(@year = params[:year], @month = params[:month])
    @prev_month = SessionAwarePost().prev_month(@year, @month)
    @next_month = SessionAwarePost().next_month(@year, @month)
  end

  def year
    @posts  = SessionAwarePost().year(@year = params[:year])
    @months = @posts.map { |post|
    # TODO: there is problem with timezone
      post.month
    }.uniq.inject({}) { |memo, month|
      memo.merge(month => @posts.select { |p| p.face_date.month == month.to_i })
    }
    @years  = SessionAwarePost().years
  end

  # GET /posts/1
  def show
    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post)
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
    if @post.update_attributes(params[:post])
      redirect_to(public_post_path(@post), :notice => 'Post was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /posts/1
  #TODO: link for post deletion doesn't exist. And more: is it possible to delete anything without JS?
  def destroy
    @post.destroy
    redirect_to(root_url)
  end

  private

  def public_post_path(post)
    show_post_path(post.to_url_params)
  end

  helper_method :public_post_path

  def find_post
    @post = SessionAwarePost().find_by_code!(params[:id])
  end

end