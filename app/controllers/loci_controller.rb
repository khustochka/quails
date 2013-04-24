class LociController < ApplicationController

  respond_to :html
  respond_to :json, only: [:save_order, :show]

  administrative

  find_record by: :slug, before: [:edit, :update, :destroy]

  # GET /locus
  def index
    @loci = Locus.list_order.group_by(&:parent_id)
  end

  # GET /locus/1
  def show
    @locus = Locus.find_by_id(params[:id]) || Locus.find_by_slug!(params[:id])
    respond_with @locus
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

  def public
    @locs_public = Locus.public
    @locs_other = Locus.where('public_index IS NULL').order(:parent_id, :slug)
  end

  def save_order
    result = params[:order]
    Locus.transaction do
      Locus.update_all(public_index: nil)
      result.each_with_index do |loc_id, i|
        Locus.where(id: loc_id).update_all(public_index: i + 1)
      end
    end
    head :ok
  end
end
