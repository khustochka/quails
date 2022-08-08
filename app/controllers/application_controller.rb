# frozen_string_literal: true

require "quails/cache_key"

class ApplicationController < ActionController::Base
  if Rails.application.config.x.features.rack_profiler
    before_action do
      if current_user.admin?
        Rack::MiniProfiler.authorize_request
      end
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include SecurityConcern
  include LocalizationConcern
  include AdministrativeConcern
  include PublicPaths
  include RecordFinder

  include ActiveStorage::SetCurrent

  private

  def allow_params(*list)
    @allowed_params = list + [:action, :controller]
  end

  def significant_params
    if @allowed_params
      params.permit(*@allowed_params)
    else
      {}
    end
  end

  helper_method :significant_params

  def expire_photo_feeds
    expire_page controller: :feeds, action: :photos, format: "xml"
    expire_page controller: :feeds, action: :photos, format: "xml", locale: "en"
    expire_page controller: :feeds, action: :photos, format: "xml", locale: "ru"
  end

  # Report a rescued error
  def report_error(exception, params = {}, &block)
    # TODO: log to Rails log
    notify_airbrake(exception, params, &block)
  end

  helper_method :report_error

  # This is required not only in correctable controllers
  def correcting?
    @correction
  end

  helper_method :correcting?

  # def default_url_options
  #   {only_path: true}
  # end
end
