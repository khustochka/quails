class EbirdController < ApplicationController

  administrative

  def index
    @files = Ebird::File.preload(:cards).all
  end

end
