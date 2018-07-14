require "ebird/ebird_client"

class Ebird::ImportsController < ApplicationController

  administrative

  def index
    date = params[:date]
    client = EbirdClient.new
    client.authenticate
    if date.present?
      @checklists = client.get_checklists_for_date(date)
    else
      last_date = Card.maximum(:observ_date) || Time.now.to_date
      @checklists = client.get_checklists_after_date(last_date)
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
