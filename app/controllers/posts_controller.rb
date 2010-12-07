class PostsController < ApplicationController

  layout 'admin', :except => [:index, :year, :show]
  layout 'public', :only => [:index, :year, :show]

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /posts
  # GET /posts.xml
  def index
    @posts =
        if (@month = params[:month])
          @year = params[:year]
          Post.month(@year, @month)
        else
          Post.paginate(:page => params[:page], :order => 'created_at DESC', :per_page => 10)
        end

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @posts }
    end
  end

  def year
    @posts = Post.year(@year = params[:year])
    @months = @posts.map { |post|
      # TODO: there is problem with timezone
      post.created_at.month
    }.uniq.inject({}) { |memo, month|
      memo.merge(month => @posts.select { |p| p.created_at.month == month })
    }
    @years = Post.years
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