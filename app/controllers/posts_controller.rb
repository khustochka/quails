class PostsController < ApplicationController

  administrative except: [:show, :hidden]

  before_filter :find_post, only: [:edit, :update, :destroy, :show, :lj_post]

  after_filter :cache_expire, only: [:create, :update, :destroy]

  # This is rendered in public layout, just raising exception when no posts are found (the case for regular user)
  def hidden
    @posts = current_user.available_posts.hidden.order('face_date DESC').page(params[:page]).per(20)
    raise ActiveRecord::RecordNotFound if @posts.blank?
  end

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
    render 'form'
  end

  # GET /posts/1/edit
  def edit
    @extra_params = @post.to_url_params
    render 'form'
  end

  # POST /posts
  def create
    @post = Post.new(params[:post])

    if @post.save
      redirect_to(public_post_path(@post), :notice => 'Post was successfully created.')
    else
      render 'form'
    end
  end

  # PUT /posts/1
  def update
    @extra_params = @post.to_url_params
    if @post.update_attributes(params[:post])
      redirect_to(public_post_path(@post), :notice => 'Post was successfully updated.')
    else
      render 'form'
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
    redirect_to(blog_url)
  end

  # POST
  def lj_post
    #user = LiveJournal::User.new(Settings.lj_user.name, Settings.lj_user.password)
    #entry = LiveJournal::Entry.new
    #entry.security = :private
    #entry.subject = post_title(@post)
    #entry.event = @post.text
    #
    #request = LiveJournal::Request::PostEvent.new(user, entry)
    #
    #request.run
    #
    #puts "Entry #{entry.itemid}, #{entry.anum}"

    redirect_to({action: :edit}, {notice: 'Posted to LJ'})
  end

  private

  def find_post
    @post = current_user.available_posts.find_by_slug!(params[:id])
  end

  def cache_expire
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :sitemap, format: 'xml'
  end

end
