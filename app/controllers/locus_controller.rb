class LocusController < ApplicationController

  layout 'admin'

  before_filter :find_locus, :except => [:index, :new, :create]

  # GET /locus
  # GET /locus.xml
  def index
    @locus = Locus.all_ordered
    @types = @locus.map { |loc|
      {:name => loc.loc_type}
    }.uniq.map { |type|
      type.merge(:locs => @locus.select { |s| s.loc_type == type[:name] })
    }

    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @locus }
    end
  end

  # GET /locus/1
  # GET /locus/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      # format.xml  { render :xml => @locus }
    end
  end

  # GET /locus/new
  # GET /locus/new.xml
  def new
    @locus = Locus.new

    respond_to do |format|
      format.html # new.html.erb
      # format.xml  { render :xml => @locus }
    end
  end

  # GET /locus/1/edit
  def edit
  end

  # POST /locus
  # POST /locus.xml
  def create
    respond_to do |format|
      if @locus.save
        format.html { redirect_to(@locus, :notice => 'Locus was successfully created.') }
        # format.xml  { render :xml => @locus, :status => :created, :location => @locus }
      else
        format.html { render :action => "new" }
        # format.xml  { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locus/1
  # PUT /locus/1.xml
  def update
    respond_to do |format|
      if @locus.update_attributes(params[:locus])
        format.html { redirect_to(@locus, :notice => 'Locus was successfully updated.') }
        # format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        # format.xml  { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locus/1
  # DELETE /locus/1.xml
  def destroy
    @locus.destroy

    respond_to do |format|
      format.html { redirect_to(locus_index_url) }
      # format.xml  { head :ok }
    end
  end

  private
  def find_locus
    @locus = Locus.find_by_code!(params[:id])
  end

  def window_caption
    case action_name
      when 'index'
        'Listing locations'
      when 'show'
        @locus.code
      when 'new', 'create'
        "Creating location  "
      when 'edit', 'update'
        "Editing #{@locus.code}"
    end
  end
end
