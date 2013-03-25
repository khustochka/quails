class CommentsController < ApplicationController

  administrative except: [:create, :reply]

  find_record before: [:show, :edit, :update, :destroy, :reply]

  # GET /comments
  # GET /comments.json
  def index
    @comments =
        params[:sort] == 'by_post' ?
            Comment.preload(:post) :
            Comment.preload(:post).reorder('created_at DESC').page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @comment }
    end
  end

  # GET /comments/1/reply
  def reply
    @parent_comment = @comment
    @post = current_user.available_posts.find_by_id!(@parent_comment.post_id)
    @comment = @parent_comment.subcomments.new(:post => @post)
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    @post = current_user.available_posts.find_by_id!(params[:comment][:post_id])
    comment_attrs = params[:comment].slice(*Comment::ALLOWED_PARAMETERS)
    comment_attrs[:name] = params[$negative_captcha]

    @comment = @post.comments.create(comment_attrs)

    @comment.approved = !@comment.like_spam? && params[:comment][:name].blank?

    respond_to do |format|
      if @comment.save
        CommentMailer.comment_posted(@comment, request.host).deliver

        to_be_reviewed = {
                @comment.parent_id =>
                    "Извините, ваш комментарий был скрыт. Он будет рассмотрен модератором.
                      <a href='#{public_comment_path(@comment)}'>Его ссылка</a>.".html_safe
            } unless @comment.approved

        format.html { redirect_to public_comment_path(@comment), notice: to_be_reviewed }
        format.json { render :json => @comment, :status => :created, :location => @comment }
      else
        format.html {
          @parent_comment = @comment.parent_comment
          render :action => "reply"
        }
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, :notice => 'Comment was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to public_post_path(@comment.post, :anchor => "comments") }
      format.json { head :ok }
    end
  end
end
