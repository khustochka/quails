class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy]

  administrative except: [:show]

  # GET /videos
  def index
    @videos = Video.all
  end

  # GET /videos/1
  def show
  end

  # GET /videos/new
  def new
    @video = Video.new
    render 'form'
  end

  # GET /videos/1/edit
  def edit
    render 'form'
  end

  # POST /videos
  def create
    @video = Video.new(video_params)

    if @video.save
      redirect_to @video, notice: 'Video was successfully created.'
    else
      render 'form'
    end
  end

  # PATCH/PUT /videos/1
  def update
    if @video.update(video_params)
      redirect_to @video, notice: 'Video was successfully updated.'
    else
      render 'form'
    end
  end

  # DELETE /videos/1
  def destroy
    @video.destroy
    redirect_to videos_url, notice: 'Video was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_video
      @video = Video.find_by_slug(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def video_params
      params.require(:video).permit(:slug, :title, :url, :description)
    end
end
