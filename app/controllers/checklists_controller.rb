class ChecklistsController < ApplicationController

  def index
    render :text => @locale
  end

end