class PagesController < ApplicationController

  caches_page :show, gzip: true

  def show
    render params[:id]
  end

end
