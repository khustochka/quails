class ApplicationController < ActionController::Base

  protect_from_forgery

#  include LocaleController

  layout 'public'

  helper_method :window_caption

  private
  def window_caption
    # returning nil will evoke ApplicationHelper::default_window_helper
  end

end
