class LociController < ApplicationController

  before_filter :find_locus, :except => [:index, :new, :create]

  # GET /loci
  # GET /loci.xml
  def index
    @page_title = 'Listing locations'
    @loci = Locus.all_ordered

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @loci }
    end
  end

  # GET /loci/1
  # GET /loci/1.xml
  def show
    @page_title = @locus.code
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @locus }
    end
  end

  # GET /loci/new
  # GET /loci/new.xml
  def new
    @page_title = 'Creating location'
    @locus = Locus.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @locus }
    end
  end

  # GET /loci/1/edit
  def edit
    @page_title = "Editing #{@locus.code}"
  end

  # POST /loci
  # POST /loci.xml
  def create
    @locus = Locus.new(params[:locus])

    respond_to do |format|
      if @locus.save
        format.html { redirect_to(@locus, :notice => 'Locus was successfully created.') }
        format.xml  { render :xml => @locus, :status => :created, :location => @locus }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /loci/1
  # PUT /loci/1.xml
  def update
    respond_to do |format|
      if @locus.update_attributes(params[:locus])
        format.html { redirect_to(@locus, :notice => 'Locus was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /loci/1
  # DELETE /loci/1.xml
  def destroy
    @locus.destroy

    respond_to do |format|
      format.html { redirect_to(loci_url) }
      format.xml  { head :ok }
    end
  end

  private
  def find_locus
    @locus = Locus.find_by_code!(params[:id])
  end

end
