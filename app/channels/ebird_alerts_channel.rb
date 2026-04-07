# frozen_string_literal: true

class EBirdAlertsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user == "admin"
    stream_for :ebird_alerts
  end
end
