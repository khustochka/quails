# frozen_string_literal: true

class ObservationsController < ApplicationController
  administrative

  find_record before: [:show, :update, :destroy]

  after_action :cache_expire, only: [:update, :destroy, :extract]

  # GET /observations/1
  def show
  end

  # PUT /observations/1
  def update
    respond_to do |format|
      if @observation.update(params[:observation])
        format.html { redirect_to observation_path(@observation), notice: "Observation was successfully updated." }
        format.json { head :no_content }
      else
        format.html { render :show }
        format.json { render json: @observation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /observations/1
  def destroy
    @observation.destroy

    head :no_content
  end

  # GET /observations/search
  def search
    preload_tables = [{ card: :locus }, :taxon]

    observs =
      params[:q]&.values&.any?(&:present?) ?
        ObservationSearch.new(params[:q]).observations
          .joins(:card, :taxon)
          .preload(preload_tables)
          .order("cards.observ_date", "cards.locus_id", "taxa.index_num").limit(params[:limit] || 200) :
        []

    respond_to do |format|
      format.html { render partial: "observations/obs_item", collection: observs }
    end
  end

  def extract
    observations = Observation.where(id: params[:obs])
    card = observations[0].card.dup
    card.observations << observations
    card.save!
    redirect_to edit_card_path(card), notice: "New card is extracted and saved. Edit if necessary."
  end

  def move
    @observations = Observation.where(id: params[:obs]).preload(taxon: :species)
    @card = @observations[0].card
    @observation_search = ObservationSearch.new(observ_date: @card.observ_date, locus_id: @card.locus_id)
  end

  private

  def cache_expire
    expire_photo_feeds
    expire_page controller: :feeds, action: :blog, format: "xml"
    expire_page controller: :feeds, action: :instant_articles, format: "xml"
  end
end
