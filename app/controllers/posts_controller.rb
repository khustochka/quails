class PostsController < ApplicationController

  require_http_auth :except => [:index, :year, :month, :show]

  layout 'admin', :except => [:index, :year, :month, :show]

  add_finder_by :code, :only => [:public_show, :edit, :update, :destroy, :show]

  # GET /
  def index
    @posts = Post.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @posts }
    end
  end

  def month
    @posts = Post.month(@year = params[:year], @month = params[:month])
    @prev_month = Post.prev_month(@year, @month)
    @next_month = Post.next_month(@year, @month)
  end

  def year
    @posts  = Post.year(@year = params[:year])
    @months = @posts.map { |post|
    # TODO: there is problem with timezone
      post.month
    }.uniq.inject({}) { |memo, month|
      memo.merge(month => @posts.select { |p| p.created_at.month == month.to_i })
    }
    @years  = Post.years
  end

  # GET /posts/1
  def show
    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post)
    end
  end

  # GET /posts/new
  def new
    @post = Post.new(:lj_url_id => 0, :lj_post_id => 0)
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
  def destroy
    @post.destroy
    redirect_to(posts_url)
  end

  private
  def public_post_path(post)
    show_post_path(post.to_url_params)
  end

  helper_method :public_post_path

end