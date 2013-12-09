class LoginController < ApplicationController

  if Quails.env.ssl?
    force_ssl only: :login_page
  end

  def login_page
    flash[:ret] = flash[:ret] || request.referrer
  end

  def login_do
    reset_session
    if User.check_credentials(params[:username], params[:password])
      current_user.set_trust_cookie
      current_user.set_admin_session
      #redirect_to request.referrer || root_url, :status => 303
      redirect_to params[:ret] || root_url(protocol: 'http'), status: 303
    else
      render text: "403 Forbidden", status: 403
    end
  end

  def logout
    reset_session
    redirect_to request.referrer || root_url, status: 303
  end

end
