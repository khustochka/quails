# frozen_string_literal: true

require "mail"

class CommentsController < ApplicationController
  administrative except: [:create, :reply, :unsubscribe_request, :unsubscribe_submit]

  find_record before: [:show, :edit, :update, :destroy, :reply]

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, only: [:create]

  # GET /comments
  # GET /comments.json
  def index
    @comments =
      params[:sort] == "by_post" ?
        Comment.preload(:post) :
        Comment.preload(:post).reorder(created_at: :desc).page(params[:page]).per(20)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @comments }
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @comment }
    end
  end

  # GET /comments/1/reply
  def reply
    @parent_comment = @comment
    @post = current_user.available_posts.find_by!(id: @parent_comment.post_id)
    @comment = @parent_comment.subcomments.new(post: @post)
    current_user.prepopulate_comment(@comment)
  end

  # GET /comments/1/edit
  def edit
  end

  # POST /comments
  # POST /comments.json
  def create
    if params[:comment].delete(:name).present?

      render plain: "Error", status: 422

    else

      @post = current_user.available_posts.find_by!(id: params[:comment].delete(:post_id))
      comment_attrs = params.require(:comment).permit(*Comment::ALLOWED_PARAMETERS)
      comment_attrs[:name] = params[CommentsHelper::REAL_NAME_FIELD]

      @comment = @post.comments.build(comment_attrs)

      @comment.approved = !@comment.like_spam?
      @comment.ip = request.remote_ip

      commenter_email = params.dig(:commenter, :email)&.strip

      if commenter_email.present?
        commenter = Commenter.find_by(email: commenter_email)

        if commenter
          if commenter.is_admin? && !current_user.admin?
            commenter = nil
            @comment.approved = false
            @comment.body << "\n\n======\n\nTried to use admin email: #{commenter_email}"
          end
        else
          commenter = Commenter.create!(name: @comment.name, email: commenter_email)
        end

        if !allowed_email?(commenter_email)
          @comment.approved = false
        end

        @comment.send_email = @comment.approved && commenter
        if @comment.send_email
          @comment.update_attribute(:unsubscribe_token, SecureRandom.urlsafe_base64(20 * 3 / 4))
        end
        @comment.commenter = commenter
      end

      respond_to do |format|
        if @comment.save
          begin
            mailer = CommentMailer.with(comment: @comment, link_options: mailer_link_options)
            mailer.notify_admin.deliver_later
            if @comment.parent_comment&.send_email? && @comment.approved
              mailer.notify_parent_author.deliver_later
            end
          rescue => e
            # Do not fail if error happened when sending email.
            report_error(e)
          end
          format.html {
            if request.xhr?
              object_to_render = @comment
              unless @comment.approved
                object_to_render = CommentScreened.new({ id: @comment.id, path: public_comment_path(@comment) })
              end
              render object_to_render, layout: false
            else
              session[:screened] = {
                parent_id: @comment.parent_id, id: @comment.id, path: public_comment_path(@comment),
              } unless @comment.approved

              redirect_to public_comment_path(@comment)
            end
          }
        else
          format.html {
            @parent_comment = @comment.parent_comment
            if request.xhr?
              render plain: @comment.errors.full_messages.to_sentence, status: :unprocessable_entity
            else
              render action: "reply"
            end
          }
        end
      end

    end
  end

  # PUT /comments/1
  # PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(params[:comment])
        format.html { redirect_to @comment, notice: "Comment was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @comment.destroy

    respond_to do |format|
      format.html { redirect_to public_post_path(@comment.post, anchor: "comments") }
      format.json { head :no_content }
    end
  end

  def unsubscribe_request
    @token = params[:token]
    raise ActiveRecord::RecordNotFound unless @token.present?

    @comment = Comment.where(unsubscribe_token: @token).first
    if @comment
      render "comments/unsubscribe_request"
    else
      render "comments/unsubscribe_not_found", status: 404
    end
  end

  def unsubscribe_submit
    @token = params[:token]
    raise ActiveRecord::RecordNotFound unless @token.present?

    @comment = Comment.where(unsubscribe_token: @token).first
    if @comment
      @comment.update_attribute(:send_email, false)
      render "comments/unsubscribe_done"
    else
      render "comments/unsubscribe_not_found", status: 404
    end
  end

  private

  def mailer_link_options
    { host: request.host, port: request.port, protocol: request.protocol }
  end

  RESTRICTED_DOMAINS = %w(localhost localhost.localdomain)

  def allowed_email?(email)
    !Mail::Address.new(email).domain.in?(RESTRICTED_DOMAINS)
  end
end
