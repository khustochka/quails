class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  include Aspects::Security
  include Aspects::Localization
  include Aspects::Administrative
  include Aspects::PublicPaths
  include Aspects::RecordFinder

  private

  def allow_params(*list)
    @allowed_params = list + [:action, :controller]
  end

  def significant_params
    if @allowed_params
      params.slice(*@allowed_params)
    else
      params
    end
  end

  helper_method :significant_params

  def expire_photo_feeds
    expire_page controller: :feeds, action: :photos, format: 'xml'
    expire_page controller: :feeds, action: :photos, format: 'xml', locale: 'en'
  end

  protected

  def pjax_layout
    "pjax"
  end

end
