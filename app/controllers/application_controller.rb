class ApplicationController < ActionController::Base

  protect_from_forgery

  include SecurityController
  include LocaleController unless $localedisabled
  include AdminController
  include PublicPathController
  include Pjax
  include FlickrApp

  extend RecordFinder

  private

  def self.cache_sweeper(*args)
    #FIXME: see https://github.com/rails/rails-observers/issues/4
  end

  #FIXME: see https://github.com/rails/rails-observers/issues/4
  def caching_allowed?
    false
  end

  def significant_params
    if @allowed_params
      params.slice(*@allowed_params)
    else
      params
    end
  end

  helper_method :significant_params

end
