class ImagesController < ApplicationController

  require_http_auth :except => :show

  layout 'admin', :except => :show

  use_jquery :only => :index

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.xml
  def index
    @images = Image.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @images }
    end
  end

  # GET /images/1
  def show
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /images/new
  def new
    @image = Image.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /images/1/edit
  def edit
    @extra_params = @image.to_url_params
  end

  # POST /images
  def create
    @image = Image.new(params[:image])
    @image.observation_ids = params[:o]

    if @image.save
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render :action => "new" #unless @image.errors.empty?
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params
    @image.observation_ids = params[:o]
    if @image.update_attributes(params[:image])
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy

    respond_to do |format|
      format.html { redirect_to(images_url) }
    end
  end
end
