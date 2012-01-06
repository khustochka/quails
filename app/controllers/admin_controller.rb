class AdminController < ApplicationController

  ask_for_credentials :only => :login

  layout 'admin'

  def login
    redirect_to root_path, :status => 303
  end

end