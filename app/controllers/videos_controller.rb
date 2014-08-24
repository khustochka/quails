class VideosController < ApplicationController
  before_action :set_video, only: [:show, :edit, :update, :destroy, :map_edit, :patch]

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
      redirect_to edit_map_video_path(@video), notice: 'Video was successfully created. Now map it!'
    else
      render 'form'
    end
  end

  # PATCH/PUT /videos/1
  def update
    if @video.update(video_params)
      if @video.mapped?
        redirect_to video_path(@video), notice: 'Video was successfully updated.'
      else
        redirect_to edit_map_video_path(@video), notice: 'Video was successfully updated. Now map it!'
      end
    else
      render 'form'
    end
  end

  # DELETE /videos/1
  def destroy
    @video.destroy
    redirect_to videos_url, notice: 'Video was successfully destroyed.'
  end

  def map_edit
    @spot = Spot.new(public: true)
  end

  def patch
    new_params = params[:video]
    respond_to do |format|
      if @video.update_attributes(new_params)
        format.html { redirect_to action: :show }
        format.json { head :no_content }
      else
        format.html { render 'form' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_video
    @video = Video.find_by(slug: params[:id])
  end

  def video_params
    @video_params ||= params.require(:video).permit(*Video::NORMAL_PARAMS).merge(observation_ids: params[:obs] || [])
  end
end
