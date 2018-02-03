require "mail"

class CommentsController < ApplicationController

  administrative except: [:create, :reply]

  find_record before: [:show, :edit, :update, :destroy, :reply]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, only: [:create]

  # GET /comments
  # GET /comments.json
  def index
    @comments =
        params[:sort] == 'by_post' ?
            Comment.preload(:post) :
            Comment.preload(:post).reorder(created_at: :desc).page(params[:page]).per(20)

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
    @post = current_user.available_posts.find_by!(id: @parent_comment.post_id)
    @comment = @parent_comment.subcomments.new(:post => @post)
    current_user.prepopulate_comment(@comment)
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create

    if params[:comment][:name].present?

      render plain: 'Error', status: 422

    else

      @post = current_user.available_posts.find_by!(id: params[:comment][:post_id])
      comment_attrs = params.require(:comment).permit(*Comment::ALLOWED_PARAMETERS)
      comment_attrs[:name] = params[CommentsHelper::REAL_NAME_FIELD]

      @comment = @post.comments.build(comment_attrs)

      @comment.approved = !@comment.like_spam?
      @comment.ip = request.remote_ip

      commenter_email = params[:commenter].try(:[], :email)

      if commenter_email
        commenter = Commenter.find_by(email: commenter_email)

        if commenter
          if commenter.is_admin? && !current_user.admin?
            commenter = nil
            @comment.approved = false
            @comment.text += "\n\n======\n\nTried to use admin email: #{commenter_email}"
          end
        else
          commenter = Commenter.create!(name: @comment.name, email: commenter_email)
        end

        if !allowed_email?(commenter_email)
          @comment.approved = false
        end

        @comment.send_email = @comment.approved && commenter

        @comment.commenter = commenter
      end

      respond_to do |format|
        if @comment.save
          CommentMailer.notify_admin(@comment, request.host).deliver_now
          if @comment.parent_comment&.send_email? && @comment.approved
            CommentMailer.notify_parent_author(@comment, request.host).deliver_now
          end

          format.html {
            if request.xhr?
              object_to_render = @comment
              unless @comment.approved
                object_to_render = CommentScreened.new({id: @comment.id, path: public_comment_path(@comment)})
              end
              render object_to_render, layout: false
            else
              flash[:screened] = {
                  @comment.parent_id => {id: @comment.id, path: public_comment_path(@comment)}
              } unless @comment.approved

              redirect_to public_comment_path(@comment)
            end
          }
        else
          format.html {
            @parent_comment = @comment.parent_comment
            render :action => "reply"
          }
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
  
  private

  RESTRICTED_DOMAINS = %w( localhost localhost.localdomain brevipes.clientvm.vps.ua )

  def allowed_email?(email)
    !Mail::Address.new(email).domain.in?(RESTRICTED_DOMAINS)
  end

end
