# frozen_string_literal: true

class LogbookController < ApplicationController
  administrative

  # Latest view covers this many days, at most one date per day.
  LATEST_DAYS = 366

  # GET /logbook
  def index
    raise ActionController::RoutingError, "Illegal argument year=#{params[:year]}" unless
      params[:year].nil? || params[:year].to_s.match?(/\A\d{4}\z/)

    @year = params[:year]&.to_i
    @years = Observation.identified.years
    @logbook_enabled = LogbookSetting.enabled.exists?

    logbook = Logbook.new
    @entries = @year ? logbook.for_year(@year) : logbook.recent(limit: LATEST_DAYS, cutoff_days: LATEST_DAYS)
  end
end
