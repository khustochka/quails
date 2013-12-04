class LoginController < ApplicationController

  ask_for_credentials :only => :login

  def login
    current_user.set_admin_cookie
    redirect_to request.referrer || root_url, :status => 303
  end

  def logout
    current_user.remove_admin_cookie
    redirect_to request.referrer || root_url, :status => 303
  end

end
