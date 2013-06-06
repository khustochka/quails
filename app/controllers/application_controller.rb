class ApplicationController < ActionController::Base

  protect_from_forgery

  include SecurityController
  include LocaleController unless $localedisabled
  include AdminController
  include PublicPathController
  include Pjax
  include FlickrApp

  extend RecordFinder

  def perform_caching
    super && !current_user.admin?
  end

  private

  def significant_params
    if @allowed_params
      params.slice(*@allowed_params)
    else
      params
    end
  end

  helper_method :significant_params

end
