class ImagesController < ApplicationController

  check_http_auth :except => [:photostream, :show]

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
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
    @extra_params = @image.to_url_params
  end

  # POST /images
  def create
    @image = Image.new(params[:image])

    if @image.save
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params
    if @image.update_attributes(params[:image])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end
end
