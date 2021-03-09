# frozen_string_literal: true

require "export/exporter"

module Ebird
  class SubmissionsController < ApplicationController

    administrative

    def index
      @files = Ebird::File.preload(:cards).order(created_at: :desc).page(params[:page])
    end

    def show
      @file = Ebird::File.find(params[:id])
    end

    def new
      search_params = params[:q] || {observ_date: Card.first_unebirded_date, end_date: Card.last_unebirded_date}
      @observation_search = Ebird::ObsSearch.new(search_params)

      @cards = @observation_search.cards.default_cards_order(:asc).preload(:locus, :post)

      name = if @cards.present?
               [
                   @cards.first.locus.country.slug,
                   @observation_search.observ_date.try(:strftime, "%Y%m%d"),
                   @observation_search.end_date.try(:strftime, "%Y%m%d")
               ].compact.uniq.join("-")
             end

      @file = Ebird::File.new(cards: @cards, name: name)
    end

    def create
      create_ebird_file(params[:ebird_file], params[:card_id])
    end

    def regenerate
      @file = Ebird::File.find(params[:id])
      create_ebird_file({name: @file.name.sub(/(\-test)?\-\d+$/, "")}, @file.card_ids)
    end

    def update
      @file = Ebird::File.find(params[:id])
      @file.update(params[:file])
      render json: {status_line: render_to_string(partial: "status_line", formats: [:html], locals: {file: @file})}
    end

    def destroy
      Ebird::File.find(params[:id]).destroy
      redirect_to action: :index
    end

    private

    def test_prefix
      if Quails.env.real_prod?
        ""
      else
        "test-"
      end
    end

    def create_ebird_file(file_params, card_ids)
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
        redirect_to ebird_submission_url(@file.id)
      else
        if @file.persisted?
          @file.destroy
        end
        @observation_search = Ebird::ObsSearch.new
        flash.alert = "Export failed"
        render :new
      end
    rescue
      @file.destroy
      raise
    end

    private

    def default_url_options
      {only_path: false}
    end

  end
end
