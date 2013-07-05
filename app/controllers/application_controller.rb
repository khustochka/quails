require "cache_key"

class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SecurityController
  include LocaleController unless $localedisabled
  include AdminController
  include PublicPathController
  include Pjax
  include FlickrApp

  extend RecordFinder

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
