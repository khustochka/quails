# frozen_string_literal: true

class PostCoresController < ApplicationController
  administrative

  before_action :find_post_core, only: [:edit, :update, :destroy]

  def new
    @post_core = PostCore.new(topic: "OBSR")
    render "form"
  end

  def edit
    render "form"
  end

  def create
    @post_core = PostCore.new(params[:post_core])
    if @post_core.save
      redirect_to new_post_path(post: { post_core_id: @post_core.id, lang: I18n.locale })
    else
      render "form"
    end
  end

  def update
    if @post_core.update(params[:post_core])
      redirect_to posts_path
    else
      render "form"
    end
  end

  def destroy
    @post_core.destroy
    redirect_to posts_path
  end

  private

  def find_post_core
    @post_core = PostCore.find(params[:id])
  end
end
