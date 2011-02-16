class AdminController < ApplicationController

  require_http_auth

  layout 'admin'

  def dashboard
  end

end