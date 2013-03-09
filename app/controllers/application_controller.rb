class ApplicationController < ActionController::Base

  protect_from_forgery

  include SecurityController
  include LocaleController if $localeenabled
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
