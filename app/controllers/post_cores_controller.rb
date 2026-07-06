# frozen_string_literal: true

class PostCoresController < ApplicationController
  administrative

  before_action :find_post_core, only: [:edit, :update, :destroy]

  def new
    @post_core = PostCore.new(topic: "OBSR")
    render "form"
  end

  def edit
    set_attach_ui
    render "form"
  end

  def create
    @post_core = PostCore.new(params[:post_core])
    if @post_core.save
      redirect_to new_post_path(post: { post_core_id: @post_core.id, lang: I18n.default_locale })
    else
      render "form"
    end
  end

  def update
    if @post_core.update(params[:post_core])
      redirect_to posts_path
    else
      set_attach_ui
      render "form"
    end
  end

  def destroy
    if @post_core.destroy
      redirect_to posts_path
    else
      redirect_to edit_post_core_path(@post_core), alert: @post_core.errors.full_messages.to_sentence
    end
  end

  private

  def find_post_core
    @post_core = PostCore.find(params[:id])
  end

  def set_attach_ui
    @observation_search = ObservationSearch.new
    @attach_core_id = @post_core.id
  end
end
