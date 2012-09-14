class ApplicationController < ActionController::Base

  protect_from_forgery

  include SecurityController
  include LayoutController
  include LocaleController
  include AdminController
  include PublicPathController
  include Pjax
  include FlickrApp

  extend RecordFinder

  use_layout 'public'

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
