# frozen_string_literal: true

class ContentSecurityController < ApplicationController
  def report
    json = request.raw_post
    params[:json] = json
    # notify_airbrake("Content security violation")
    Rails.logger.warn("[CSP-REPORT] #{json}")
    if Rails.env.test?
      raise "Content security violation: #{json}"
    end
  end
end
