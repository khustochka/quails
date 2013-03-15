class PagesController < ApplicationController

  caches_action :show, :error, unless: -> { current_user.admin? || current_user.has_admin_cookie? }

  def show
    render params[:id]
  end

  def error
    @status = params[:code]
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
