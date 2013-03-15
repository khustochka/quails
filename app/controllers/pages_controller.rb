class PagesController < ApplicationController

  caches_page :show, :error, gzip: true, unless: -> { current_user.admin? || current_user.has_admin_cookie? }

  def show
    render params[:id]
  end

  def error
    @status = env["PATH_INFO"][1..-1]
    render @status, layout: 'error', status: @status
  end

  private
  def caching_allowed?
    if @status
      request.get?
    else
      super
    end
  end

end
