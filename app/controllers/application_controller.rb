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

# TODO: Default redirect status should be 301 for public pages, 302 left for administrative
#  def redirect_to(options = {}, response_status = {})
#    new_status = response_status.dup
#    unless (options.is_a?(Hash) && options.key?(:status)) || response_status.key?(:status)
#      new_status.merge!(:status => :moved_permanently)
#    end
#    super(options, new_status)
#  end

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
