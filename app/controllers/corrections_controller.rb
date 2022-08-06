class CorrectionsController < ApplicationController
  administrative

  before_action :set_correction, only: %i[ start edit update destroy ]

  # GET /corrections
  def index
    @corrections = Correction.all
  end

  # GET /corrections/1/start
  def start
    object = @correction.results.first
    if object
      redirect_to [:edit, object, { correction: @correction.id }]
    else
      flash[:notice] = "You have reached the last record!"
      redirect_to [:edit, @correction]
    end
  end

  # GET /corrections/new
  def new
    @correction = Correction.new
  end

  # GET /corrections/1/edit
  def edit
  end

  # POST /corrections
  def create
    @correction = Correction.new(correction_params)

    if @correction.save
      redirect_to [:edit, @correction], notice: "Correction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /corrections/1
  def update
    if @correction.update(correction_params)
      redirect_to [:edit, @correction], notice: "Correction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /corrections/1
  def destroy
    @correction.destroy
    redirect_to corrections_url, notice: "Correction was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_correction
    @correction = Correction.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def correction_params
    params.require(:correction).permit(:model_classname, :query, :sort_column)
  end
end
