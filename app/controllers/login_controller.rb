class LoginController < ApplicationController

  if Quails.env.ssl?
    force_ssl only: :login_page
  end

  def login_page
  end

  def login_do
    if User.check_credentials(params[:username], params[:password])
      current_user.set_trust_cookie
      current_user.set_admin_session
      #redirect_to request.referrer || root_url, :status => 303
      redirect_to root_url(protocol: 'http'), status: 303
    else
      current_user.drop_admin_session
      render text: "403 Forbidden", status: 403
    end
  end

  def logout
    current_user.drop_admin_session
    redirect_to request.referrer || root_url, status: 303
  end

end
