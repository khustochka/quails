class LociController < ApplicationController

  administrative

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /locus
  def index
    @locus_by_type = Locus.list_order.includes(:parent).group_by(&:loc_type)
  end

  # GET /locus/1
  def show
  end

  # GET /locus/new
  def new
    @locus = Locus.new
    render :form
  end

  # GET /locus/1/edit
  def edit
    render :form
  end

  # POST /locus
  def create
    @locus = Locus.new(params[:locus])
    if @locus.save
      redirect_to(@locus, :notice => 'Locus was successfully created.')
    else
      render :form
    end
  end

  # PUT /locus/1
  def update
    if @locus.update_attributes(params[:locus])
      redirect_to(@locus, :notice => 'Locus was successfully updated.')
    else
      render :form
    end
  end

  # DELETE /locus/1
  def destroy
    @locus.destroy
    #TODO: rescue ActiveRecord::DeleteRestrictionError showing a notice and later - options for substitution
    redirect_to(loci_url)
  end
end
