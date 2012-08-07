class LoginController < ApplicationController

  ask_for_credentials :only => :login

  layout 'admin'

  def login
    cookies.signed[User.cookie_name] = {value: User.cookie_value, expires: 1.month.from_now}
    redirect_to root_url, :status => 303
  end

end
