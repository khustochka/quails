# frozen_string_literal: true

class LoginController < ApplicationController
  # User can get to login page in 3 ways:
  # 1. Redirect from admin path accessed when not logged in (sets session[:ret])
  # 2. Clicking Login on any page when not logged in (we try to go back to the referrer after login)
  # 3. Entering login URL manually (no return url)
  # This way if login fails after variant 1 or 2, session[:ret] remains set, and if the user at some point
  # gets back by manually entering the url, session[:ret] will be used as a return url.
  # This is annoying but minor issue. Leaving it for now. Possible solutions:
  # - cleanup session[:ret] in before_action for all actions except login? (too much)
  # - use a separate cookie?
  def new
    session[:ret] = safe_referrer_params || session[:ret]
    render layout: "login"
  end

  def login
    ret = session[:ret]
    csrf_token = session[:_csrf_token]
    reset_session
    if CredentialsCheck.check_credentials(params[:username], params[:password])
      set_trust_cookie
      set_admin_session
      return_url = if ret
        url_for(ret)
      else
        root_url
      end
      redirect_to return_url, status: :see_other
    else
      # Restore ret value for retries,
      # Restore csrf token to allow using form on the previous page
      session[:ret] = ret
      session[:_csrf_token] = csrf_token
      render plain: "403 Forbidden", status: :forbidden
    end
  end

  def logout
    reset_session
    redirect_to request.referrer || root_url, status: :see_other
  end

  private

  def safe_referrer_params
    ref = request.referrer
    if ref
      begin
        uri = URI.parse(ref)
        # We consider it valid if it was recognized and host is the same
        if uri.host == request.host
          Rails.application.routes.recognize_path(ref)
        end
      rescue ActionController::RoutingError, URI::InvalidURIError
        nil
      end
    end
  end

  def set_admin_session
    session[:admin] = true
  end

  def set_trust_cookie
    cookies.signed[TRUST_COOKIE_NAME] =
      { value: TRUST_COOKIE_VALUE, expires: 1.month.from_now, httponly: true }
  end
end
