# frozen_string_literal: true

class LociController < ApplicationController

  administrative

  find_record by: :slug, before: [:edit, :update, :destroy]

  # GET /locus
  def index
    @term = params[:term]
    @loci = if @term.present?
                 Search::LociSearch.new(Locus.cached_ancestry_preload, @term).find
               else
                 Locus.order(:id).cached_ancestry_preload.page(params[:page])
               end
    @loci = @loci.preload(:observations, :patch_observations)
    preload_parent(@loci)
    if request.xhr?
      render partial: "loci/table", layout: false
    else
      render
    end
    # @loci = Locus.order(:id).preload(:observations, :patch_observations).page(params[:page])
  end

  # GET /locus/1
  def show
    @locus = Locus.find_by(id: params[:id]) || Locus.find_by!(slug: params[:id])
    respond_to do |format|
      format.html {  }
      format.json { render json: @locus }
    end
  end

  # GET /locus/new
  def new
    @locus = Locus.new(params[:locus])
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
      redirect_to(edit_locus_path(@locus), notice: "Locus was successfully created.")
    else
      render :form
    end
  end

  # PUT /locus/1
  def update
    if @locus.update(params[:locus])
      if params[:commit] == "Save and next >>"
        nextloc = Locus.where(ebird_location_id: nil).where("id > ?", @locus.id).order(id: :asc).limit(1).first
        redirect_to(edit_locus_path(nextloc), notice: "Sucess. Next one:")
      else
        redirect_to(edit_locus_path(@locus), notice: "Locus was successfully updated.")
      end
    else
      render :form
    end
  end

  # DELETE /locus/1
  def destroy
    @locus.destroy
    # TODO: rescue ActiveRecord::DeleteRestrictionError showing a notice and later - options for substitution
    redirect_to(loci_url)
  end

  def public
    @locs_public = Locus.locs_for_lifelist
    @locs_other = Locus.sort_by_ancestry(Locus.where("public_index IS NULL"))
  end

  def save_order
    result = params[:order]
    Locus.transaction do
      Locus.update_all(public_index: nil)
      result.each_with_index do |loc_id, i|
        Locus.where(id: loc_id).update_all(public_index: i + 1)
      end
    end
    head :no_content
  end

  private
  def preload_parent(loci)
    parent_ids = loci.map(&:parent_id)
    parents = Locus.where(id: parent_ids).index_by(&:id)
    loci.each do |loc|
      loc.send(:set_parent, parents[loc.parent_id])
    end
  end
end
