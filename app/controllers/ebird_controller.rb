require 'ebird/exporter'

class EbirdController < ApplicationController

  administrative

  def index
    @files = Ebird::File.preload(:cards)
  end

  def new
    @file = Ebird::File.new
    @observation_search = ObservationSearch.new
  end

  def create
    @file = Ebird::File.create(params[:ebird_file])

    if @file.valid?
      @file.update_attribute(:name, "#{@file.name}_#{@file.id}")

      cards_rel = Card.where(id: params[:card_id])

      result = EbirdExporter.new(@file.name, cards_rel).export
    else
      result = false
    end

    if result
      @file.cards = cards_rel
      @files = Ebird::File.preload(:cards)
      render :index, notice: 'Successfully created CSV file'
    else
      @file.destroy
      @observation_search = ObservationSearch.new
      @file = Ebird::File.new(params[:ebird_file])
      render :new, alert: "Export failed"
    end

  end

end
