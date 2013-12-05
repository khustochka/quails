class LoginController < ApplicationController

  if Rails.env.production?
    force_ssl only: :login_page
  end

  def login_page
  end

  def login_do
    if User.check_credentials(params[:username], params[:password])
      current_user.set_trust_cookie
      current_user.set_admin_cookie
      #redirect_to request.referrer || root_url, :status => 303
      redirect_to url_for(controller: :blog, action: :front_page, only_path: false, protocol: 'http'), status: 303
    else
      current_user.remove_admin_cookie
      render text: "403 Forbidden", status: 403
    end
  end

  def logout
    current_user.remove_admin_cookie
    redirect_to request.referrer || root_url, status: 303
  end

end
