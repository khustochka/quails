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
      format.xml  { render :xml => @images }
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
  end

  # POST /images
  def create
    @image = Image.new(params[:image])

    respond_to do |format|
      if @image.save
        format.html { redirect_to(@image, :notice => 'Image was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /images/1
  def update
    respond_to do |format|
      if @image.update_attributes(params[:image])
        format.html { redirect_to(@image, :notice => 'Image was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
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
