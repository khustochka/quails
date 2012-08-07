class LoginController < ApplicationController

  ask_for_credentials :only => :login

  layout 'admin'

  def login
    current_user.set_admin_cookie
    redirect_to root_url, :status => 303
  end

end
