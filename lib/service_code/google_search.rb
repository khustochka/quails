# frozen_string_literal: true

require 'service_code/service_code'

class GoogleSearch < ServiceCode

  CODE_ENV_VAR = -"quails_google_cse"

  # FIXME: temporarily disable CSE: in does not work in IE7/8 (JS) and standard Google search actually looks better.
  def self.configured?
    false
  end

  def render
    @view.render partial: 'partials/search', object: self
  end

  def form_url
    if configured?
      "//www.google.com/cse"
    else
      "//www.google.com/search"
    end
  end

end
