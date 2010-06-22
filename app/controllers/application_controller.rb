class ApplicationController < ActionController::Base

  protect_from_forgery

#  include LocaleController
  include AssetsController
  include LayoutController

  layout 'public'

  stylesheet 'global', 'public'
  stylesheet 'formtastic', :only => [:new, :edit, :create, :update]

  helper_method :window_caption

  private
  def window_caption
    # returning nil will evoke ApplicationHelper::default_window_helper
  end

end
