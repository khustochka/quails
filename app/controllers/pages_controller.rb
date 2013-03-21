class PagesController < ApplicationController

  caches_action :show, layout: false
  caches_page :error, gzip: true, unless: -> { current_user.admin? || current_user.has_admin_cookie? }

  def show
    render params[:id]
  end

  def error
    @code = env["PATH_INFO"][1..-1]
    render @code, layout: 'error', formats: %w(html), status: @code
  end

  private
  def caching_allowed?
    if @code
      request.get?
    else
      super
    end
  end

end
