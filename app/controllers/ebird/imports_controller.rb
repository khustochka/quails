require "ebird/ebird_client"

class Ebird::ImportsController < ApplicationController

  administrative

  def index
    date = params[:date]
    if date
      client = EbirdClient.new
      client.authenticate
      @checklists = client.get_checklists_for_date(date)
    end

  end

  def create

  end

end
