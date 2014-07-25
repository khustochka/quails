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
    begin
      @file = Ebird::File.create(params[:ebird_file])

      if @file.valid?
        @file.update_attribute(:name, "#{@file.name}-#{test_prefix}#{@file.id}")

        cards_rel = Card.where(id: params[:card_id])

        result = EbirdExporter.new(@file.name, cards_rel).export
      else
        result = false
      end

      if result
        @file.cards = cards_rel
        @files = Ebird::File.preload(:cards)
        flash.notice = "Successfully created CSV file #{ActionController::Base.helpers.link_to(@file.name, @file.full_url)}".html_safe
        render :index
      else
        @file.destroy
        @observation_search = ObservationSearch.new
        @file = Ebird::File.new(params[:ebird_file])
        flash.alert = "Export failed"
        render :new
      end
    rescue
      @file.destroy
      raise
    end

  end

  private

  def test_prefix
    if Quails.env.real_prod?
      ''
    else
      'test-'
    end
  end

end
