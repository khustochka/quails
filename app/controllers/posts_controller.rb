class PostsController < ApplicationController

  layout 'admin', :except => [:index, :show]
  layout 'public', :only => [:index, :show]

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.xml
  def index
    @posts = Post.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 10)

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @posts }
    end
  end

  # GET /posts/1
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new(:lj_url_id => 0, :lj_post_id => 0)
  end

  # GET /posts/1/edit
  def edit
  end

  # POST /posts
  def create
    @post = Post.new(params[:post])

    if @post.save
      redirect_to(@post, :notice => 'Post was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /posts/1
  def update
    if @post.update_attributes(params[:post])
      redirect_to(@post, :notice => 'Post was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to(posts_url)
  end
end