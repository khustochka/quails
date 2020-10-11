# frozen_string_literal: true

class ApplicationController < ActionController::Base

  before_action do
    if current_user.admin?
      Rack::MiniProfiler.authorize_request
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
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml', locale: 'en'
  end

end
