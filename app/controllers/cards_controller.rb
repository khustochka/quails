class CardsController < ApplicationController

  administrative

  after_filter :cache_expire, only: [:create, :update, :destroy, :attach]
  cache_sweeper :lifelist_sweeper

  # GET /cards
  # GET /cards.json
  def index

    @search = ObservationSearch.new(params[:q])

    @cards = @search.cards.order(params[:sort] || 'observ_date DESC, locus_id').preload(:locus, :post).page(params[:page])

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

    respond_to do |format|
      format.html { render :form }
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

    respond_to do |format|
      if @card.update_attributes(params[:card])
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

  private

  def cache_expire
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :blog, format: 'xml'
  end
end
