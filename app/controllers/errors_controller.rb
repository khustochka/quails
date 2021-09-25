# frozen_string_literal: true

class ErrorsController < ApplicationController
  caches_page :show, gzip: true, unless: -> { current_user.admin? || has_trust_cookie? }

  def show
    @error_status = request.path_info[1..-1].to_i
    render @error_status.to_s, layout: "error", formats: [:html], status: @error_status
  end

  private
  def caching_allowed?
    if @error_status
      request.get? || request.head?
    else
      super
    end
  end
end
