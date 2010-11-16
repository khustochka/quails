class LocusController < ApplicationController

  layout 'admin'

  use_jquery :only => :index

  add_finder_by :code, :only => [:show, :edit, :update, :destroy]

  # GET /locus
  def index
    @locus = Locus.all_ordered
    @types = @locus.map { |loc|
      {:name => loc.loc_type}
    }.uniq.map { |type|
      type.merge(:locs => @locus.select { |s| s.loc_type == type[:name] })
    }
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

    respond_to do |format|
      format.html { redirect_to(locus_index_url) }
    end
  end
end
