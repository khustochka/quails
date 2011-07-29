class ImagesController < ApplicationController

  require_http_auth :except => [:index, :show]

  layout 'admin', :except => [:index, :show]

  use_jquery :only => [:index, :new, :edit, :create, :update]
  javascript JQ_UI_FILE, 'tmpl', 'suggest_over_combo', 'images', :only => [:new, :edit, :create, :update]
  stylesheet 'autocomplete', :only => [:new, :edit, :create, :update]

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.xml
  def index
    @images = Image.order('created_at DESC').page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @images }
    end
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
