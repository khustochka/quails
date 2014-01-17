class ErrorsController < ApplicationController

  caches_page :show, gzip: true, unless: -> { current_user.admin? || current_user.has_trust_cookie? }

  def show
    @code = env["PATH_INFO"][1..-1]
    render @code, layout: 'error', formats: %w(html), status: @code.to_i
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
