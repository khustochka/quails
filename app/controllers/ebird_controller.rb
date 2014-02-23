class EbirdController < ApplicationController

  administrative

  def index
    @files = Ebird::File.preload(:cards)
  end

  def new
    @file = Ebird::File.new
    @observation_search = ObservationSearch.new
  end

  def create
    @file = Ebird::File.create(params[:ebird_file])
  end

end
