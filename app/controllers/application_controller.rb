class ApplicationController < ActionController::Base

  protect_from_forgery

  include SecurityController
  include LayoutController
  include LocaleController
  include AdminController
  include PublicPathController

  extend ModelFinderForController

  layout 'public'

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
