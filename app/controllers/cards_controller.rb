# frozen_string_literal: true

require "ebird/ebird_checklist"

class CardsController < ApplicationController

  administrative

  after_action :cache_expire, only: [:create, :update, :destroy, :attach]

  # GET /cards
  # GET /cards.json
  def index
    @observation_search = ObservationSearch.new(params[:q])

    @cards = @observation_search.cards.
        default_cards_order(:desc).preload(:locus, :post)

    if !request.xhr?
      @cards = @cards.page(params[:page]).per(10)
    else
      @cards = @cards.limit(30)
    end


    @post = Post.where(id: params[:new_post_id]).first

    respond_to do |format|
      format.html {
        if request.xhr?
          render @cards, layout: false
        else
          render 'index'
        end
      }
      format.json { render json: @cards }
    end
  end

  # GET /cards/1
  # GET /cards/1.json
  def show
    @card = Card.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @card }
    end
  end

  # GET /cards/new
  # GET /cards/new.json
  def new
    @card = Card.new(params[:card])
    last_date = Card.maximum(:observ_date)
    if last_date
      @card.observ_date ||= last_date + 1
    end

    respond_to do |format|
      format.html { render :form, layout: !request.xhr? }
      format.json { render json: @card }
    end
  end

  # GET /cards/1/edit
  def edit
    @card = Card.find(params[:id])
    render :form
  end

  # POST /cards
  # POST /cards.json
  def create
    @card = Card.new(params[:card])
    @card.resolved = true if params[:resolve]

    respond_to do |format|
      if @card.save
        format.html { redirect_to edit_card_path(@card), notice: 'Card was successfully created.' }
        format.json { render json: @card, status: :created, location: @card }
      else
        format.html { render :form }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /cards/1
  # PUT /cards/1.json
  def update
    @card = Card.find(params[:id])
    params[:card][:resolved] = true if params[:resolve]

    respond_to do |format|
      if @card.update(params[:card])
        format.html { redirect_to edit_card_path(@card), notice: 'Card was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :form }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card = Card.find(params[:id])
    @card.destroy

    respond_to do |format|
      format.html { redirect_to cards_url }
      format.json { head :no_content }
    end
  end

  def attach
    card = Card.find(params[:id])
    observations = Observation.where(id: params[:obs])
    card.observations << observations

    redirect_to card, notice: "#{observations.size} observations successfully moved"
  end

  def import
    ebird_id = params[:ebird_id]

    @card = Card.new

    if ebird_id.present?

      checklist = EbirdChecklist.new(ebird_id).fetch!

      @card = checklist.to_card

      @ebird_location = checklist.location_string

    else
      flash.now[:alert] = "Missing ebird checklist id."
    end

    render "form"

  end

  private

  def cache_expire
    expire_photo_feeds
    expire_page controller: :feeds, action: :blog, format: 'xml'
    expire_page controller: :feeds, action: :instant_articles, format: 'xml'
  end
end
