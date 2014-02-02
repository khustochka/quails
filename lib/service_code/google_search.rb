require 'service_code/service_code'

class GoogleSearch < ServiceCode

  CODE_ENV_VAR = 'quails_google_cse'.freeze

  def render
    @view.render partial: 'partials/search', locals: {form_url: form_url, code: config.code}
  end

  def form_url
    if config.code.present?
      "http://google.com/cse"
    else
      "http://google.com/search"
    end
  end

end
