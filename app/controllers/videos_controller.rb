# frozen_string_literal: true

class VideosController < ApplicationController
  find_record by: :slug, before: [:show, :edit, :update, :destroy, :map_edit, :patch]

  administrative except: [:index, :show]

  # GET /videos
  def index
    if params[:page].to_i == 1
      redirect_to page: nil
    else
      page = (params[:page] || 1).to_i
      @videos = Video.preload(:species).order(created_at: :desc).page(page).per(10)
      #@feed = 'photos'
      if @videos.empty? && page != 1
        raise ActiveRecord::RecordNotFound
      else
        render :index
      end
    end
  end

  # GET /videos/1
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
    render "form"
  end

  # GET /videos/1/edit
  def edit
    render "form"
  end

  # POST /videos
  def create
    @video = Video.new(video_params)

    if @video.save
      redirect_to edit_map_video_path(@video), notice: "Video was successfully created. Now map it!"
    else
      render "form"
    end
  end

  # PATCH/PUT /videos/1
  def update
    if @video.update(video_params)
      if @video.mapped?
        redirect_to video_path(@video), notice: "Video was successfully updated."
      else
        redirect_to edit_map_video_path(@video), notice: "Video was successfully updated. Now map it!"
      end
    else
      render "form"
    end
  end

  # DELETE /videos/1
  def destroy
    @video.destroy
    redirect_to videos_url, notice: "Video was successfully destroyed."
  end

  def map_edit
    @spot = Spot.new(public: true)
  end

  def patch
    new_params = params[:video]
    respond_to do |format|
      if @video.update(new_params)
        format.html { redirect_to action: :show }
        format.json { head :no_content }
      else
        format.html { render "form" }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def video_params
    @video_params ||= params.require(:video).permit(*Video::NORMAL_PARAMS).merge(observation_ids: params[:obs] || [])
  end
end
