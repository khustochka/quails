%w( layout locale security model_finder_for public_path ).each do |file|
  require "mixins/#{file}_controller"
end

class ApplicationController < ActionController::Base

  protect_from_forgery

#  include LocaleController
  include SecurityController
  include LayoutController
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
