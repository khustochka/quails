class PostsController < ApplicationController

  administrative :except => [:show]

  before_filter :find_post, only: [:edit, :update, :destroy, :show]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # GET /posts/1
  def show
    if @post.month != params[:month].to_s || @post.year != params[:year].to_s
      redirect_to public_post_path(@post), :status => 301
    end
    @comments = @post.comments.group_by(&:parent_id)
    @comment = @post.comments.new(:parent_id => 0)
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
    redirect_to(blog_url)
  end

  private

  def find_post
    @post = current_user.available_posts.find_by_code!(params[:id])
  end

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end

end
