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
    image = params[:image]
    image[:observation_ids] = cleanup_observation_ids(image[:observation_ids] || [])
    @image = Image.new(image)

    @image.validate_observations(image[:observation_ids])

    if @image.errors.blank? && @image.save
      redirect_to(public_image_path(@image), :notice => 'Image was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /images/1
  def update
    @extra_params = @image.to_url_params
    image = params[:image]
    observation_ids = cleanup_observation_ids(image.delete(:observation_ids) || [])
    # TODO: I need a smarter way to do all these validations
    @image.validate_observations(observation_ids)

    if @image.errors.blank? && @image.update_attributes(image.merge({:observation_ids => observation_ids}))
      redirect_to(public_image_path(@image), :notice => 'Image was successfully updated.')
    else
      @image.assign_attributes(image)
      # TODO: probably hits the DB. no observation_ids_was.
      @image.observations.reload if observation_ids.blank?
      render :action => "edit"
    end
  end

  # DELETE /images/1
  def destroy
    @image.destroy
    redirect_to(images_url)
  end
  
  private
  def cleanup_observation_ids(list)
    list.uniq
  end
  
end
