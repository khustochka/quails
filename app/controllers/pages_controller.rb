class PagesController < ApplicationController

  administrative except: [:show, :error]

  caches_page :error, gzip: true, unless: -> { current_user.admin? || current_user.has_admin_cookie? }

  find_record by: :slug, before: [:show, :edit, :update, :destroy]

  def index
    @pages = Page.all
  end

  def new
    @page = Page.new
    render :form
  end

  def create
    @page = Page.new(params[:page])
    if @page.save
      redirect_to(show_page_url(@page.slug), :notice => 'Page was successfully created.')
    else
      render :form
    end
  end

  def edit
    render :form
  end

  def update
    @page.update_attributes(params[:page])
    if @page.save
      redirect_to(show_page_url(@page.slug), :notice => 'Page was successfully updated.')
    else
      render :form
    end
  end

  def show
    @page_title = @page.title
    @robots = @page.meta.robots
  end

  def error
    @code = env["PATH_INFO"][1..-1]
    render @code, layout: 'error', formats: %w(html), status: @code
  end

  private
  def caching_allowed?
    if @code
      request.get?
    else
      super
    end
  end

end
