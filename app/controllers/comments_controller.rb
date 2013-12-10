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

    @admin_id = Commenter.where(is_admin: true).pluck(:id).first

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
    current_user.prepopulate_comment(@comment)
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

    @comment = @post.comments.build(comment_attrs)

    if params[:comment][:name].present?

      render text: 'Error', status: 422

    else

      @comment.approved = !@comment.like_spam? && params[:comment][:name].blank?
      @comment.ip = request.remote_ip

      commenter_email = params[:commenter].try(:[], :email)

      if @comment.send_email && commenter_email.present?
        commenter = Commenter.find_by_email(commenter_email) ||
            Commenter.create!(name: @comment.name, email: commenter_email)
        @comment.commenter = commenter
      end

      respond_to do |format|
        if @comment.save
          CommentMailer.notify_admin(@comment, request.host).deliver
          if @comment.parent_comment && @comment.parent_comment.send_email? && @comment.approved
            CommentMailer.notify_parent_author(@comment, request.host).deliver
          end

          flash[:notice] = {
              @comment.parent_id =>
                  "Извините, ваш комментарий был скрыт. Он будет рассмотрен модератором.
                      <a href='#{public_comment_path(@comment)}'>Его ссылка</a>.".html_safe
          } unless @comment.approved

          format.html { redirect_to public_comment_path(@comment) }
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
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update_attributes(params[:comment])
        format.html { redirect_to @comment, :notice => 'Comment was successfully updated.' }
        format.json { head :no_content }
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
      format.json { head :no_content }
    end
  end
end
