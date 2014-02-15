class PatchesController < ApplicationController
  before_action :set_patch, only: [:show, :edit, :update, :destroy]

  administrative

  # GET /patches
  def index
    @patches = Patch.all
  end

  # GET /patches/1
  def show
  end

  # GET /patches/new
  def new
    @patch = Patch.new
  end

  # GET /patches/1/edit
  def edit
  end

  # POST /patches
  def create
    @patch = Patch.new(patch_params)

    if @patch.save
      redirect_to @patch, notice: 'Patch was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /patches/1
  def update
    if @patch.update(patch_params)
      redirect_to @patch, notice: 'Patch was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /patches/1
  def destroy
    @patch.destroy
    redirect_to patches_url, notice: 'Patch was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_patch
      @patch = Patch.find_by_name(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def patch_params
      params.require(:patch).permit(:name, :lat, :lng)
    end
end
