class PagesController < ApplicationController

  administrative except: [:show_public]

  find_record by: :slug, before: [:show, :show_public, :edit, :update, :destroy]

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
      redirect_to(page_url(@page.slug), :notice => 'Page was successfully created.')
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
      redirect_to(page_url(@page.slug), :notice => 'Page was successfully updated.')
    else
      render :form
    end
  end

  def show
    @page_title = @page.formatted.title
    @robots = @page.meta.robots
    render :show
  end

  def show_public
    if @page.public? || current_user.admin?
      @page_title = @page.formatted.title
      @robots = @page.meta.robots
      render :show
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
