class ImagesController < ApplicationController

  requires_admin_authorized :except => [:photostream, :show]

  layout 'admin', :except => [:photostream, :show]

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /images
  def index
    @images = Image.page(params[:page])
  end

  # GET /photostream
  def photostream
    @images = Image.order('created_at DESC').page(params[:page]).per(20)
  end

  # GET /images/1
  def show
    if params[:species] != @image.species_for_url
      redirect_to @image.to_url_params, :status => 301
    end
  end

  # GET /images/new
  def new
    @image = Image.new
    render 'form'
  end

  # GET /images/1/edit
  def edit
    @extra_params = @image.to_url_params
    render 'form'
  end

  # POST /images
  def create
    @image = Image.new

    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render 'form'
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params
    
    if @image.update_with_observations(params[:image], params[:obs])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      render 'form'
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end  
end
