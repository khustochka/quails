%w(assets layout locale security model_finder_for public_path).each do |file|
  require "mixins/#{file}_controller"
end

class ApplicationController < ActionController::Base

  protect_from_forgery

#  include LocaleController
  include SecurityController
  include AssetsController
  include LayoutController
  include PublicPathController

  extend ModelFinderForController

  helper_method :page_title

  layout 'public'

  stylesheet 'global', 'public'
  stylesheet 'forms', :only => [:new, :edit, :create, :update]

# TODO: Default redirect status should be 301 for public pages, 302 left for administrative
#  def redirect_to(options = {}, response_status = {})
#    new_status = response_status.dup
#    unless (options.is_a?(Hash) && options.key?(:status)) || response_status.key?(:status)
#      new_status.merge!(:status => :moved_permanently)
#    end
#    super(options, new_status)
#  end

  private
  def page_title
    @page_title
    # returning nil will evoke ApplicationHelper::default_page_title
  end

  def SessionAwarePost
    @post_rel ||= admin_session? ? Post : Post.public
  end

end
