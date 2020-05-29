class ErrorsController < ApplicationController

  caches_page :show, gzip: true, unless: -> { current_user.admin? || has_trust_cookie? }

  def show
    @code = request.path_info[1..-1].to_i
    render @code.to_s, layout: 'error', formats: [:html], status: @code
  end

  private
  def caching_allowed?
    if @code
      request.get? || request.head?
    else
      super
    end
  end

end
