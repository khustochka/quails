class LoginController < ApplicationController

  if Quails.env.ssl?
    force_ssl only: :login_page
    skip_before_action :force_http
  end

  # User can get to login page in 3 ways:
  # 1. Redirect from admin path accessed when not logged in (sets session[:ret])
  # 2. Clicking Login on any page when not logged in (we try to go back to the referrer after login)
  # 3. Entering login URL manually (no return url)
  # This way if login fails after variant 1 or 2, session[:ret] remains set, and if the user at some point
  # gets back by manually entering the url, session[:ret] will be used as a return url.
  # This is annoying but minor issue. Leaving it for now. Possible solutions:
  # - cleanup session[:ret] in before_action for all actions except login? (too much)
  # - use a separate cookie?
  def login_page
    session[:ret] = safe_referrer_params || session[:ret]
    render layout: 'login'
  end

  def login_do
    ret = session[:ret]
    reset_session
    if User.check_credentials(params[:username], params[:password])
      current_user.set_trust_cookie
      current_user.set_admin_session
      return_url = if ret
        url_for(ret.merge(admin_pages_url_options))
      else
        root_url(admin_pages_url_options)
      end
      redirect_to return_url, status: 303
    else
      # Restore ret value for retries
      session[:ret] = ret
      render text: "403 Forbidden", status: 403
    end
  end

  def logout
    reset_session
    redirect_to request.referrer || root_url, status: 303
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
        else
          nil
        end
      rescue ActionController::RoutingError, URI::InvalidURIError
        nil
      end
    end
  end

end
