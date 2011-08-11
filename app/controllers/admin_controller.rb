class AdminController < ApplicationController

  require_http_auth

  layout 'admin'

  def login
    redirect_to root_path
  end

end