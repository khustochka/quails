require 'export/exporter'

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
    @observation_search = Ebird::ObsSearch.new
  end

  def create
    create_ebird_file(params[:ebird_file], params[:card_id])
  end

  def regenerate
    @file = Ebird::File.find(params[:id])
    create_ebird_file({name: @file.name.sub(/(\-test)?\-\d+$/, '')}, @file.card_ids)
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

  def create_ebird_file(file_params, card_ids)
    begin
      @file = Ebird::File.new(file_params)

      cards_rel = Card.where(id: card_ids)

      @file.cards = cards_rel

      if @file.save
        @file.update_attribute(:name, "#{@file.name}-#{test_prefix}#{@file.id}")
        result = Exporter.ebird(@file.name, cards_rel).export
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

end
