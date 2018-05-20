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
    params.permit(:c)
    checklists = params.fetch(:c, nil)
    if checklists
      checklists.each do |cl|
        ImportEbirdChecklistJob.perform_later(cl[:ebird_id], cl[:locus_id])
      end
      flash.notice = "Import jobs enqueued."
    else
      flash.notice = "No checklists to import."
    end
    redirect_to ebird_imports_path
  end

end
