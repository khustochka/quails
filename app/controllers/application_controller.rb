class ApplicationController < ActionController::Base

  protect_from_forgery

#  include LocaleController
  include AssetsController
  include LayoutController

  extend ModelFinderForController

  helper_method :page_title

  layout 'public'

  stylesheet 'global', 'public'
  stylesheet 'formtastic', 'forms', :only => [:new, :edit, :create, :update]

  private
  def page_title
    @page_title
    # returning nil will evoke ApplicationHelper::default_page_title
  end

end
