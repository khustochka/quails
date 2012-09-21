class AuthoritiesController < ApplicationController

  respond_to :json, only: [:save_order]

  administrative

  find_record by: :slug, before: [:show, :edit, :update, :destroy]

  # GET /authority
  def index
    @authorities = Authority.scoped
  end

  # GET /authority/1
  def show
    @species = @authority.book_species.extend(SpeciesArray)
  end

  # GET /authority/new
  def new
    @authority = Authority.new
    render :form
  end

  # GET /authority/1/edit
  def edit
    render :form
  end

  # POST /authority
  def create
    @authority = Authority.new(params[:authority])
    if @authority.save
      redirect_to(@authority, :notice => 'Authority was successfully created.')
    else
      render :form
    end
  end

  # PUT /authority/1
  def update
    if @authority.update_attributes(params[:authority])
      redirect_to(@authority, :notice => 'Authority was successfully updated.')
    else
      render :form
    end
  end

  # DELETE /authority/1
  def destroy
    @authority.destroy
    #TODO: rescue ActiveRecord::DeleteRestrictionError showing a notice and later - options for substitution
    redirect_to(authorities_url)
  end
end
