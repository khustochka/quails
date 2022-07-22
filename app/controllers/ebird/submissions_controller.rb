# frozen_string_literal: true

require "export/exporter"

module Ebird
  class SubmissionsController < ApplicationController
    administrative

    STORAGE_CONFIGS = {
      local: {
        service: "Disk",
        root: Pathname("tmp/csv"),
      },
      s3: {
        service: "S3",
        region: ENV["S3_BUCKET_REGION"] || ENV["AWS_REGION"],
        bucket: ENV["EBIRD_CSV_BUCKET"],
      },
    }
    URL_EXPIRATION_SECONDS = 600

    def index
      @files = Ebird::File.preload(:cards).order(created_at: :desc).page(params[:page])
    end

    def show
      respond_to do |format|
        format.html {
          @file = Ebird::File.find(params[:id])
        }
        format.csv {
          filename = params[:id]
          @file = Ebird::File.find_by(name: filename)
          if @file
            redirect_to private_url(@file.full_name)
          else
            raise ActiveRecord::RecordNotFound
          end
        }
      end
    end

    def new
      search_params = params[:q] || { observ_date: Card.first_unebirded_date, end_date: Card.last_unebirded_date }
      @observation_search = Ebird::ObsSearch.new(search_params)

      @cards = @observation_search.cards.default_cards_order(:asc).preload(:locus, :post)

      name = if @cards.present?
        [
          @cards.first.locus.country.slug,
          @observation_search.observ_date.try(:strftime, "%Y%m%d"),
          @observation_search.end_date.try(:strftime, "%Y%m%d"),
        ].compact.uniq.join("-")
      end

      @file = Ebird::File.new(cards: @cards, name: name)
    end

    def create
      create_ebird_file(params[:ebird_file], params[:card_id])
    end

    def regenerate
      @file = Ebird::File.find(params[:id])
      create_ebird_file({ name: @file.name.delete_prefix("test-").sub(/\-\d+$/, "") }, @file.card_ids)
    end

    def update
      @file = Ebird::File.find(params[:id])
      @file.update(params[:file])
      render json: { status_line: render_to_string(partial: "status_line", formats: [:html], locals: { file: @file }) }
    end

    def destroy
      Ebird::File.find(params[:id]).destroy
      redirect_to action: :index
    end

    private

    def test_prefix
      if Quails.env.live?
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
        @file.update_attribute(:name, "#{test_prefix}#{@file.name}-#{@file.id}")
        result = Exporter.ebird(filename: @file.name, cards: cards_rel, storage: storage_service).export
      else
        # FIXME: this is hack. For some reason errors on cards are not preserved after validation.
        @file.cards.each { |c| c.valid?(:ebird_post) }
        result = false
      end

      if result
        # rubocop:disable Rails/OutputSafety
        flash.notice =
          "Successfully created CSV file #{helpers.link_to(@file.full_name, ebird_submission_path(id: @file.name, format: :csv))}".html_safe
        # rubocop:enable Rails/OutputSafety
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

    def private_url(fname)
      # Does not work for disk service, because services are not defined in storage.yml.
      # Not fixing this because feature is not used.
      storage_service.url(
        fname, expires_in: URL_EXPIRATION_SECONDS,
        filename: ActiveStorage::Filename.new(fname), disposition: :attachment, content_type: "text/csv"
      )
    end

    def storage_service
      @storage_service ||= ActiveStorage::Service.configure(storage_key, STORAGE_CONFIGS)
    end

    def storage_key
      if Rails.env.production? || ENV["EBIRD_CSV_BUCKET"]
        :s3
      else
        :local
      end
    end
  end
end
