require 'ebird/exporter'

class EbirdController < ApplicationController

  administrative

  def index
    @files = Ebird::File.order(:created_at).preload(:cards)
  end

  def show
    @file = Ebird::File.find(params[:id])
  end

  def new
    @file = Ebird::File.new
    @observation_search = ObservationSearch.new
  end

  def create
    begin
      @file = Ebird::File.new(params[:ebird_file])

      cards_rel = Card.where(id: params[:card_id])

      @file.cards = cards_rel

      if @file.save
        @file.update_attribute(:name, "#{@file.name}-#{test_prefix}#{@file.id}")
        result = EbirdExporter.new(@file.name, cards_rel).export
      else
        # FIXME: this is hack. For some reason errors on cards are not preserved after validation.
        @file.cards.each {|c| c.valid?(:ebird_post)}
        result = false
      end

      if result
        flash.notice = "Successfully created CSV file #{ActionController::Base.helpers.link_to(@file.name, @file.download_url)}".html_safe
        redirect_to @file
      else
        if @file.persisted?
          @file.destroy
        end
        @observation_search = ObservationSearch.new
        flash.alert = "Export failed"
        render :new
      end
    rescue
      @file.destroy
      raise
    end

  end

  def update
    @file = Ebird::File.find(params[:id])
    @file.update_attributes(params[:file])
    render json: {status_line: render_to_string(partial: 'status_line', formats: [:html], locals: {file: @file})}
  end

  def destroy
    Ebird::File.find(params[:id]).destroy
    redirect_to action: :index
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
