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
    checklists = params.require(:c)
    checklists.each do |cl|
      ImportEbirdChecklistJob.perform_later(cl[:ebird_id], cl[:locus_id])
    end
    flash.notice = "Import jobs enqueued."
    redirect_to ebird_imports_path
  end

end
